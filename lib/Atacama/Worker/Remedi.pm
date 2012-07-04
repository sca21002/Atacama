package Atacama::Worker::Remedi;
use Moose;
extends 'Atacama::Worker::Base';
use Atacama::Schema;
use MooseX::Types::Moose qw(Bool Str);
use MooseX::Types::Path::Class qw(File Dir);
use DateTime;
use Carp;
use File::Copy;
use CAM::PDF;
use Remedi::DigiFooter;
use Remedi::Mets;
use Remedi::CSV;

has '+log_config_basename' => (
    default => 'log4perl_remedi.conf',
);


has '+log_basename' => (
    default => 'remedi.log',                        
);

has 'does_copy_files' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_copy_files',
    lazy => 1,
);

has 'does_csv' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_csv',
    lazy => 1,
);

has 'does_digifooter' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_digifooter',
    lazy => 1,
);

has 'does_mets' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_mets',
    lazy => 1,
);

has 'csv_file' => (
    is => 'ro',
    isa => File,
    builder => '_build_csv_file',
    lazy => 1,
);

has 'csv_basename' => (
    is => 'ro',
    isa => Str,
    builder => '_build_csv_basename',
    lazy => 1,
);

has 'csv_save_dir' => (
    is => 'ro',
    isa => Dir,
    builder => '_build_csv_save_dir',
    lazy => 1,
);

has 'remedi_config_file' => (
    is => 'ro',
    isa => File,
    lazy => 1,
    coerce => 1,
    builder => '_build_remedi_config_file',
);

has 'scanfiles' => (
    is => 'ro',
    isa => 'ArrayRef[Atacama::Schema::Result::Scanfile]',
    lazy => 1,
    builder => '_build_scanfiles',
);

has 'source_pdf' => (
    is => 'rw',
    isa => File,
);

sub _build_csv_basename {
    my $self = shift;
    
    return $self->order_id . '.csv';
}


sub _build_csv_file {
    my $self = shift;
    
    return Path::Class::File->new($self->work_dir, $self->csv_basename);
}

sub _build_csv_save_dir {
    my $self = shift;
    
    my $csv_save_dir = Path::Class::Dir->new($self->work_base, 'csv_save');
    unless (-d $csv_save_dir) {
        File::Path::make_path($csv_save_dir->stringify)
            or die "Coldn't create $csv_save_dir: $!";
    }
    return $csv_save_dir;
}

sub _build_does_copy_files {
    my $self = shift;
    
    return exists $self->job->arg->{copy_files}
           && $self->job->arg->{copy_files};
}

sub _build_does_csv {
    my $self = shift;
    
    return exists $self->job->arg->{csv}
           && $self->job->arg->{csv};    
}

sub _build_does_digifooter {
    my $self = shift;
    
    return exists $self->job->arg->{digifooter}
           && $self->job->arg->{digifooter};    
}

sub _build_does_mets {
    my $self = shift;
    
    return exists $self->job->arg->{mets}
           && $self->job->arg->{mets};    
}

sub _builder_log_dir { (shift)->work_dir }

sub _build_remedi_config_file {
    my $self = shift;
    
    my $remedi_config_file = $self->job->arg->{configfile}
        or $self->log->croak("Keine Remedi-Konfigurationsdatei");
    return $remedi_config_file;
}

sub _build_scanfiles {
    my $self = shift;
    
    
    my @scanfiles = $self->atacama_schema->resultset('Scanfile')->search(
        { order_id => $self->order_id },
        { order_by => 'filename' },
    )->all;
    $self->log->croak("Keine Scandateien in der Datenbank") unless (@scanfiles);
    return \@scanfiles;   
}



sub copy_pdf {
    my $self = shift;
    
    my $source = Path::Class::File->new( $self->job->arg->{source_pdf_name} );
    my $dest   = Path::Class::File->new($self->work_dir, $self->order_id . '.pdf');  
    if ($source->basename =~ /^UBR\d{2}A\d{6}\.pdf/) {
        $self->log->info("EOD-PDF: " . $source);
        my $doc = CAM::PDF->new($source) || $self->log->logdie("$CAM::PDF::errstr\n");
        my $pagenums = '1-4,' . $doc->numPages;
        if (!$doc->deletePages($pagenums)) {
            $self->log->logdie("Failed to delete a page\n");
        } else {
            $self->log->info("4 Seiten vorne und 1 hinten im PDF gelöscht!");    
        }
        $doc->cleanoutput($dest);
    }
    else {
        copy($source, $dest) 
        or $self->log->logdie("Konnte $source nicht nach $dest kopieren: $!");
    }

    $self->source_pdf($dest);  		
    $self->log->info("$source --> $dest");    
    
}

sub copy_scanfiles {
    my $self = shift;

    foreach my $scanfile ( @{$self->scanfiles} ) {
        $self->log->debug("Scandatei: " . $scanfile->filename);
        my $source_dir = $scanfile->filepath;
        my $source = File::Spec->catfile($source_dir, $scanfile->filename);
        my $dest   = File::Spec->catfile($self->work_dir,   $scanfile->filename);
        copy($source, $dest) 
            or $self->log->logdie(
                "Konnte $source nicht nach $dest kopieren: $!"
            );
        $self->log->info("$source --> $dest");
    }    
    
}

sub save_csv_file {
    my $self = shift;
    
    File::Copy::move(
        $self->csv_file->stringify,
        $self->csv_save_dir->stringify,
    ) or croak(
        'Konnte ' . $self->csv_file . ' nicht nach '
                  . $self->csv_savedir . ' verschieben.'
    );
}

sub empty_work_dir {
    my $self = shift;
    
    my $work_dir = $self->work_dir;
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
    my $self = shift;
    
    my $csv_saved = $self->save_csv_file if -e $self->csv_file;
    $self->empty_work_dir;
    my $log_msg = $self->restore_csv_file if $csv_saved;
    return $log_msg ? "Alte CSV-Datei gesichert als $log_msg" : '';
}

sub restore_csv_file {
    my $self = shift;
    
    my $csv_file_saved
        = Path::Class::File->new($self->csv_save_dir, $self->csv_basename);
    my $now = DateTime->now->strftime("%Y-%m-%d-%H-%M");
    my $csv_saved_target 
        = Path::Class::File->new(
                $self->work_dir, $self->order_id . '_' . $now . '.csv'
        ); 
    File::Copy::copy($csv_file_saved->stringify, $csv_saved_target->stringify)
        or croak("Konnte $csv_file_saved nicht nach $csv_saved_target kopieren");
    return $csv_saved_target->stringify;
}

sub start_digifooter {
    my $self = shift;
    
    my %init_arg = (
        image_path => $self->order_id,
        title      => $self->order->titel->titel_isbd || '',
        author     => $self->order->titel->autor_avs || '',
        configfile => $self->remedi_config_file,
        source_pdf_name => $self->job->arg->{source_pdf_name},
    );
    foreach my $key (qw/resolution_correction source_format/) {
        $init_arg{$key} = $self->job->arg->{$key} if $self->job->arg->{$key};
    }
    while (my($key, $val) = each %init_arg) { $self->log->info("$key => $val") } 
    Remedi::DigiFooter->new_with_config(%init_arg)->make_footer;    
    
}

sub start_mets {
    my $self = shift;

    my %init_arg = ( 
        image_path   => $self->order_id,
        bv_nr        => $self->order->titel->bvnr,
        # shelf_number => $titel->signatur,
        title        => $self->order->titel->titel_isbd,
        # author       => $titel->autor_avs,
        configfile   => $self->remedi_config_file,
    );
    $init_arg{shelf_number}
        =  $self->order->titel->signatur if $self->order->titel->signatur;
    $init_arg{author}
        =  $self->order->titel->autor_avs if $self->order->titel->autor_avs;
    Remedi::Mets->new_with_config(%init_arg)->make_mets;    

}

sub start_csv {
    my $self = shift;
    
    my %init_arg = (
        image_path => $self->order_id,
        configfile => $self->remedi_config_file,
    );
    Remedi::CSV->new_with_config(%init_arg)->make_csv;     
    
}

around 'work' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $result = $self->$orig(@_);
    my $log_msg = $self->prepare_work_dir if $self->does_copy_files;
    my $log = $self->log;
    $log->info('Programm gestartet');
    $log->info($log_msg) if $log_msg;
    $self->order->update({status_id => 22});

    if ($self->does_copy_files) {    
        $self->copy_scanfiles;
        $self->copy_pdf if $self->job->arg->{source_format} eq 'PDF';
    }

    if ($self->does_digifooter) {
        $self->start_digifooter;
    }

    if ($self->does_mets) {
        $self->start_mets;
    }

    if ($self->does_csv) {
        $self->start_csv;
    }
    
    $self->job->completed();

    $self->order->update({status_id => 26});
    return 1;
};

1;
