package Atacama::Worker::Remedi;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Remedi;
use Scalar::Util qw(blessed);
use Carp;


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
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work():"
            . ref $job_theschwartz . " ist kein Objekt vom Typ TheSchwartz::Job"       
         ) unless blessed($job_theschwartz) && $job_theschwartz->isa( 'TheSchwartz::Job' );
    my $job = Atacama::Worker::Job::Remedi->new(job => $job_theschwartz);


    my $log_msg = prepare_work_dir($job) if $job->does_copy_files;
    my $log = $job->log;
    $log->info('Programm gestartet');
    $log->info($log_msg) if $log_msg;
    $job->order->update({status_id => 22});

    if ($job->does_copy_files) {    
        $job->copy_scanfiles;
        $job->copy_pdf if $job->job_arg->{source_format} eq 'PDF';
    }

    if ($job->does_digifooter) {
        $job->start_digifooter;
    }

    if ($job->does_mets) {
        $job->start_mets;
    }

    if ($job->does_csv) {
        $job->start_csv;
    }
    
    $job->completed();

    $job->order->update({status_id => 26});
    return 1;
}

1;
