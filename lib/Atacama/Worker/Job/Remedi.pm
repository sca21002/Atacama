package Atacama::Worker::Job::Remedi;
use Moose;
extends 'Atacama::Worker::Job::Base';
use MooseX::Types::Moose qw(Bool Str);
use MooseX::Types::Path::Class qw(File Dir);
use File::Copy qw();
use CAM::PDF;
use Remedi::DigiFooter;
use Remedi::Mets;
use Remedi::CSV;
use Data::Dumper;


has 'csv_basename' => (
    is => 'ro',
    isa => Str,
    builder => '_build_csv_basename',
    lazy => 1,
);

has 'csv_file' => (
    is => 'ro',
    isa => File,
    builder => '_build_csv_file',
    lazy => 1,
);

has 'csv_save_dir' => (
    is => 'ro',
    isa => Dir,
    builder => '_build_csv_save_dir',
    lazy => 1,
);

has 'does_copy_files' => (
    is => 'ro',
    isa => Bool,
);

has 'does_csv' => (
    is => 'ro',
    isa => Bool,
);

has 'does_digifooter' => (
    is => 'ro',
    isa => Bool,
);

has 'does_mets' => (
    is => 'ro',
    isa => Bool,

);

has 'ocrfiles' => (
    is => 'ro',
    isa => 'ArrayRef[Atacama::Schema::Result::Ocrfile]',
    lazy => 1,
    builder => '_build_ocrfiles',
);

has 'remedi_configfile' => (
    is => 'ro',
    isa => File,
    coerce => 1,
    required => 1,
);

has 'resolution_correction' => (
    is => 'ro',
    isa => Str,
);

has 'scanfiles' => (
    is => 'ro',
    isa => 'ArrayRef[Atacama::Schema::Result::Scanfile]',
    lazy => 1,
    builder => '_build_scanfiles',
);

has 'source_format' => (
    is => 'ro',
    isa => Str,
);

has 'source_pdf' => (
    is => 'rw',
    isa => File,
    predicate => 'has_source_pdf',
    coerce => 1,
);

around BUILDARGS => sub {
      my $orig  = shift;
      my $class = shift;
      my %args = @_;

      warn "BUILDARGS: " . Dumper(\%args);
      return $class->$orig(@_);
};

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

sub _build_ocrfiles {
    my $self = shift;
    
    
    my @ocrfiles = $self->atacama_schema->resultset('Ocrfile')->search(
        { order_id => $self->order_id },
        { order_by => 'filename' },
    )->all;
    $self->log->info("Keine OCR-Dateien in der Datenbank") unless (@ocrfiles);
    return \@ocrfiles;   
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

sub copy_ocrfiles {
    my $self = shift;

    my $log = $self->log;
    foreach my $ocrfile ( @{$self->ocrfiles} ) {
        $log->debug("OCR-Datei: " . $ocrfile->filename);
        my $source_dir = $ocrfile->filepath;
        my $source = Path::Class::File->new($source_dir,    $ocrfile->filename);
        my $dest   = Path::Class::File->new($self->work_dir, $ocrfile->filename);
        File::Copy::copy($source->stringify, $dest->stringify) 
            or $log->logdie("Konnte $source nicht nach $dest kopieren: $!");
        $log->info("$source --> $dest");
    }    
}

sub copy_pdf {
    my $self = shift;
    
    my $log = $self->log;
    my $source = $self->source_pdf;
    $log->logdie('Keine PDF-Quelldatei!') unless $source;
    my $dest = Path::Class::File->new($self->work_dir, $self->order_id . '.pdf');  
    if ($source->basename =~ /^UBR\d{2}A\d{6}\.pdf/) {
        $log->info("EOD-PDF: " . $source);
        my $doc = CAM::PDF->new($source) || $log->logdie("$CAM::PDF::errstr\n");
        my $pagenums = '1-4,' . $doc->numPages;
        if (!$doc->deletePages($pagenums)) {
            $log->logdie("Failed to delete a page\n");
        } else {
            $log->info("4 Seiten vorne und 1 hinten im PDF gelöscht!");    
        }
        $doc->cleanoutput($dest);
    }
    else {
        File::Copy::copy($source->stringify, $dest->stringify) 
        or $log->logdie("Konnte $source nicht nach $dest kopieren: $!");
    }

    $self->source_pdf($dest);  		
    $log->info("$source --> $dest");    
}


sub copy_scanfiles {
    my $self = shift;

    my $log = $self->log;
    foreach my $scanfile ( @{$self->scanfiles} ) {
        $log->debug("Scandatei: " . $scanfile->filename);
        my $source_dir = $scanfile->filepath;
        my $source = Path::Class::File->new($source_dir, $scanfile->filename);
        my $dest   = Path::Class::File->new($self->work_dir,   $scanfile->filename);
        File::Copy::copy($source->stringify, $dest->stringify) 
            or $log->logdie("Konnte $source nicht nach $dest kopieren: $!");
        $log->info("$source --> $dest");
    }    
}

sub empty_work_dir {
    my $self = shift;
    
    my $work_dir = $self->work_dir;
    $work_dir->rmtree({keep_root => 1, error => \my $err});
    $self->log->logdie('Fehler beim Löschen von ' . $work_dir . Dumper($err))
        if @$err;
    return 1; 
}

sub prepare_work_dir {
    my $self = shift;
    
    my $csv_saved = $self->save_csv_file() if -e $self->csv_file;
    $self->empty_work_dir();
    my $csv_file_restored = $self->restore_csv_file if $csv_saved;
    $self->log->info("Alte CSV-Datei gesichert als $csv_file_restored")
        if $csv_file_restored;
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
        or $self->log->logdie(
            "Konnte $csv_file_saved nicht nach $csv_saved_target kopieren"
        );
    return $csv_saved_target->stringify;
}

sub save_csv_file {
    my $self = shift;
    
    File::Copy::move(
        $self->csv_file->stringify,
        $self->csv_save_dir->stringify,
    ) or $self->log->logdie(
        'Konnte ' . $self->csv_file . ' nicht nach '
                  . $self->csv_savedir . ' verschieben.'
    );
}


sub start_digifooter {
    my $self = shift;
    
    my $log = $self->log;
    my %init_arg = (
        image_path => $self->order_id,
        title      => $self->order->titel->titel_isbd || '',
        author     => $self->order->titel->autor_avs || '',
        configfile => $self->remedi_configfile,
        source_pdf => $self->source_pdf && $self->source_pdf->stringify,
    );
    foreach my $key (qw/resolution_correction source_format/) {
        $init_arg{$key} = $self->$key if $self->$key;
    }
    while (my($key, $val) = each %init_arg) { $log->info("$key => $val") }
    my $traits = (%{Config::Any->load_files({
        files => [$self->remedi_configfile],
        use_ext => 1, 
        driver_args => { General => { -ForceArray => 1 }}
    })->[0]})[1]{traits} || [ qw/DestFormat::PDF/ ];
    $log->info('Traits: ' . Dumper($traits));
    my $class = Remedi::DigiFooter->with_traits(@$traits);
    my $instance = $class->new_with_config(%init_arg);
    $log->logdie('Instanz kann nicht get_dest_format')
        unless $instance->can('get_dest_format');
    $instance->make_footer;    
}


sub start_mets {
    my $self = shift;

    my $log = $self->log;
    my $conf = Config::Any->load_files( {
        files => [$self->remedi_configfile],
        use_ext => 1,
    } );
    my ($filename, $config) = %{shift @$conf};
    my $usetypes = $config->{usetypes} || [qw(archive reference thumbnail)];
    if ( @{$self->ocrfiles} ) {
        push @$usetypes, 'ocr' unless grep { $_ eq 'ocr' } @$usetypes;
        $log->info('OCR-Dateien gefunden');
    }
    else { $log->info('Keine OCR-Dateien gefunden'); }
    
    
    my %init_arg = ( 
        image_path   => $self->order_id,
        bv_nr        => $self->order->titel->bvnr,
        title        => $self->order->titel->titel_isbd,
        configfile   => $self->remedi_configfile,
        usetypes     => $usetypes,
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
        configfile => $self->remedi_configfile,
    );
    Remedi::CSV->new_with_config(%init_arg)->make_csv;     
    
}

sub run {
    my $self = shift;
    
    my $log_msg = $self->prepare_work_dir() if $self->does_copy_files;
    my $log = $self->log;
    $log->info('Programm gestartet');
    $log->info($log_msg) if $log_msg;
    $self->order->update({status_id => 22});
    if ($self->does_copy_files) {
        $log->trace('Does copy files');    
        $self->copy_scanfiles();
        $self->copy_pdf() if $self->source_format eq 'PDF';
        $self->copy_ocrfiles();
    }

    if ($self->does_digifooter) {
        $log->trace('Does digifooter');
        $self->start_digifooter();
    }

    if ($self->does_mets) {
        $log->trace('Does mets');
        $self->start_mets();
    }


    if ($self->does_csv) {
        $log->trace('Does csv');
        $self->start_csv();
    }    
    $self->order->update({status_id => 26});    
}

1;
