package Atacama::Worker::Remedi;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Remedi;
use Scalar::Util qw(blessed);
use Carp;
use File::Copy;
use CAM::PDF;
use Remedi::DigiFooter;
use Remedi::Mets;
use Remedi::CSV;

my $log_file_name;


sub copy_pdf {
    my $job = shift;
    
    my $source = Path::Class::File->new( $job->arg->{source_pdf_name} );
    my $dest   = Path::Class::File->new($job->work_dir, $job->order_id . '.pdf');  
    if ($source->basename =~ /^UBR\d{2}A\d{6}\.pdf/) {
        $job->log->info("EOD-PDF: " . $source);
        my $doc = CAM::PDF->new($source) || $job->log->logdie("$CAM::PDF::errstr\n");
        my $pagenums = '1-4,' . $doc->numPages;
        if (!$doc->deletePages($pagenums)) {
            $job->log->logdie("Failed to delete a page\n");
        } else {
            $job->log->info("4 Seiten vorne und 1 hinten im PDF gelöscht!");    
        }
        $doc->cleanoutput($dest);
    }
    else {
        copy($source, $dest) 
        or $job->log->logdie("Konnte $source nicht nach $dest kopieren: $!");
    }

    $job->source_pdf($dest);  		
    $job->log->info("$source --> $dest");    
    
}

sub copy_scanfiles {
    my $job = shift;

    foreach my $scanfile ( @{$job->scanfiles} ) {
        $job->log->debug("Scandatei: " . $scanfile->filename);
        my $source_dir = $scanfile->filepath;
        my $source = File::Spec->catfile($source_dir, $scanfile->filename);
        my $dest   = File::Spec->catfile($job->work_dir,   $scanfile->filename);
        copy($source, $dest) 
            or $job->log->logdie(
                "Konnte $source nicht nach $dest kopieren: $!"
            );
        $job->log->info("$source --> $dest");
    }    
    
}



sub empty_work_dir {
    my $job = shift;
    
    my $work_dir = $job->work_dir;
    $work_dir->rmtree({keep_root => 1, error => \my $err});
    if (@$err) {
        my $err_str;
        for my $diag (@$err) {
            my ($file, $message) = %$diag;
            if ($file eq '') {
                $err_str .= "general error: $message\n";
            }
            else {
                $err_str .= "problem unlinking $file: $message\n";
            }
        }
        croak("Konnte $work_dir nicht loeschen: $err_str"); 
    } else {
        return 1;
    }    
}

sub get_logfile_name { $log_file_name }

sub prepare_work_dir {
    my $job = shift;
    
    my $csv_saved = save_csv_file($job) if -e $job->csv_file;
    empty_work_dir($job);
    my $log_msg = $self->restore_csv_file if $csv_saved;
    return $log_msg ? "Alte CSV-Datei gesichert als $log_msg" : '';
}


sub restore_csv_file {
    my $job = shift;
    
    my $csv_file_saved
        = Path::Class::File->new($job->csv_save_dir, $job->csv_basename);
    my $now = DateTime->now->strftime("%Y-%m-%d-%H-%M");
    my $csv_saved_target 
        = Path::Class::File->new(
                $job->work_dir, $job->order_id . '_' . $now . '.csv'
        ); 
    File::Copy::copy($csv_file_saved->stringify, $csv_saved_target->stringify)
        or croak("Konnte $csv_file_saved nicht nach $csv_saved_target kopieren");
    return $csv_saved_target->stringify;
}


sub save_csv_file {
    my $job = shift;
    
    File::Copy::move(
        $job->csv_file->stringify,
        $job->csv_save_dir->stringify,
    ) or croak(
        'Konnte ' . $job->csv_file . ' nicht nach '
                  . $job->csv_savedir . ' verschieben.'
    );
}


sub start_digifooter {
    my $job = shift;
    
    my %init_arg = (
        image_path => $job->order_id,
        title      => $job->order->titel->titel_isbd || '',
        author     => $job->order->titel->autor_avs || '',
        configfile => $job->remedi_config_file,
        source_pdf_name => $job->arg->{source_pdf_name},
    );
    foreach my $key (qw/resolution_correction source_format/) {
        $init_arg{$key} = $job->arg->{$key} if $job->arg->{$key};
    }
    while (my($key, $val) = each %init_arg) { $job->log->info("$key => $val") } 
    Remedi::DigiFooter->new_with_config(%init_arg)->make_footer;    
    
}


sub start_mets {
    my $job = shift;

    my %init_arg = ( 
        image_path   => $job->order_id,
        bv_nr        => $job->order->titel->bvnr,
        # shelf_number => $titel->signatur,
        title        => $job->order->titel->titel_isbd,
        # author       => $titel->autor_avs,
        configfile   => $job->remedi_config_file,
    );
    $init_arg{shelf_number}
        =  $job->order->titel->signatur if $job->order->titel->signatur;
    $init_arg{author}
        =  $job->order->titel->autor_avs if $job->order->titel->autor_avs;
    Remedi::Mets->new_with_config(%init_arg)->make_mets;    

}


sub start_csv {
    my $job = shift;
    
    my %init_arg = (
        image_path => $job->order_id,
        configfile => $job->remedi_config_file,
    );
    Remedi::CSV->new_with_config(%init_arg)->make_csv;     
    
}


sub work {
    my $class = shift;
    my $job_theschwartz = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Remedi';
    my $job = Atacama::Worker::Job::Remedi->new(job => $job_theschwartz);
    $log_file_name = $job->log_file_name;
    my $log_msg = prepare_work_dir($job) if $job->does_copy_files;
    my $log = $job->log;
    $log->info('Programm gestartet');
    $log->info($log_msg) if $log_msg;
    $job->order->update({status_id => 22});

    if ($job->does_copy_files) {    
        copy_scanfiles($job);
        copy_pdf($job) if $job->arg->{source_format} eq 'PDF';
    }

    if ($job->does_digifooter) {
        start_digifooter($job);
    }

    if ($job->does_mets) {
        start_mets($job);
    }

    if ($job->does_csv) {
        start_csv($job);
    }
    
    $job->completed();

    $job->order->update({status_id => 26});
    return 1;
}

1;
