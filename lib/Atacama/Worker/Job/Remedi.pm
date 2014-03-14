use utf8;
package Atacama::Worker::Job::Remedi;
use Atacama::Types qw(Bool Dir File Path Str);
use Moose;
extends 'Atacama::Worker::Job::Base';
use File::Copy qw();
use CAM::PDF;
use Remedi::DigiFooter;
use Remedi::METS;
use Remedi::CSV;
use Data::Dumper;
use Path::Tiny;


has 'csv_basename' => (
    is => 'ro',
    isa => Str,
    builder => '_build_csv_basename',
    lazy => 1,
);

has 'csv_file' => (
    is => 'ro',
    isa => Path,
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
    default => 0,
);

has 'does_csv' => (
    is => 'ro',
    isa => Bool,
    default => 0,
);
            

has 'does_digifooter' => (
    is => 'ro',
    isa => Bool,
    default => 0,
);

has 'does_mets' => (
    is => 'ro',
    isa => Bool,
    default => 0,
);

has 'image_path' => (
    is => 'ro',
    isa => Path,
    coerce => 1,
    lazy => 1,
    builder => '_build_image_path',
);

has 'is_thesis_workflow' => (
    is => 'ro',
    isa => Bool,
    default => 0,
);

has '+log_config_basename' => (
    is => 'ro',
    isa => Str,
    default => 'log4perl_remedi.conf',
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
    predicate => 'has_source_format',
);

has 'source_pdf_file' => (
    is => 'rw',
    isa => File,
    coerce => 1,
);

around BUILDARGS => sub {
      my $orig  = shift;
      my $class = shift;
      my %args = @_;

      # warn 'BUILDARGS: ' . Dumper(\%args);
      return $class->$orig(@_);
};

sub _build_csv_basename {
    my $self = shift;
    
    return $self->order_id . '.csv';
}

sub _build_csv_file {
    my $self = shift;
    
    return path($self->working_dir, $self->csv_basename);
}

sub _build_csv_save_dir {
    my $self = shift;
    
    my $csv_save_dir = path($self->working_base, 'csv_save');
    $csv_save_dir->mkpath( {error => \my $err} );
    $self->log->logdie("Coldn't create '$csv_save_dir': " . Dumper($err))
        if @$err;
    return $csv_save_dir;
}

sub _build_image_path { path( (shift)->order_id ) }

sub _build_log {
    my $self = shift;
   
    Log::Log4perl->init($self->log_config_file->stringify);
    return Log::Log4perl->get_logger('Atacama::Worker::Job::Remedi');
}

sub _build_ocrfiles {
    my $self = shift;
    
    
    my @ocrfiles = $self->atacama_schema->resultset('Ocrfile')->search(
        { order_id => $self->order_id },
        { order_by => 'filename' },
    )->all;
    $self->log->info("No ocr files found in database") unless (@ocrfiles);
    return \@ocrfiles;   
}



sub _build_scanfiles {
    my $self = shift;
    
    
    my @scanfiles = $self->atacama_schema->resultset('Scanfile')->search(
        { order_id => $self->order_id },
        { order_by => 'filename' },
    )->all;
    $self->log->croak("No scan files found in database") unless (@scanfiles);
    return \@scanfiles;   
}

sub copy_ocrfiles {
    my $self = shift;

    my $log = $self->log;
    foreach my $ocrfile ( @{$self->ocrfiles} ) {
        $log->debug("ocr file: " . $ocrfile->filename);
        my $source_dir = path($ocrfile->filepath);
        my $source = path($source_dir,        $ocrfile->filename);
        my $dest   = path($self->working_dir, $ocrfile->filename);
        $source->copy($dest)
            or $log->logdie("couldn't copy '$source' to '$dest': $!");
        $log->info("$source --> $dest");
    }    
}

sub copy_pdf {
    my $self = shift;
    
    my $log = $self->log;
    my $source = $self->source_pdf_file;
    $log->logdie('No pdf source file!') unless $source;
    my $dest = path($self->working_dir, $self->order_id . '.pdf');  
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
        $source->copy($dest) 
        or $log->logdie("Couldn't copy '$source' to '$dest': $!");
    }

    $self->source_pdf_file($dest);  		
    $log->info("$source --> $dest");    
}


sub copy_scanfiles {
    my $self = shift;

    my $log = $self->log;
    foreach my $scanfile ( @{$self->scanfiles} ) {
        $log->debug("Scandatei: " . $scanfile->filename);
        my $source_dir = $scanfile->filepath;
        my $source = path($source_dir, $scanfile->filename);
        my $dest   = path($self->working_dir, $scanfile->filename);
        $source->copy($dest) 
            or $log->logdie("Couldn't copy '$source' to '$dest': $!");
        $log->info("$source --> $dest");
    }    
}

sub empty_working_dir {
    my $self = shift;
    
    my $working_dir = $self->working_dir;
    $working_dir->remove_tree( {keep_root => 1, error => \my $err} );
    $self->log->logdie(
        "Couldn't remove '$working_dir' recursively " . Dumper($err)
    )  if @$err;
    return 1; 
}

sub prepare_working_dir {
    my $self = shift;
    
    my $csv_saved = $self->save_csv_file() if $self->csv_file->exists;
    $self->empty_working_dir();
    my $csv_file_restored = $self->restore_csv_file if $csv_saved;
    $self->log->info("old CSV file saved as '$csv_file_restored'")
        if $csv_file_restored;
}

sub restore_csv_file {
    my $self = shift;
    
    my $csv_file_saved = path($self->csv_save_dir, $self->csv_basename);
    my $now = DateTime->now->strftime("%Y-%m-%d-%H-%M");
    my $csv_saved_target 
        = path($self->working_dir, $self->order_id . '_' . $now . '.csv');
    $csv_file_saved->copy($csv_saved_target)
        or $self->log->logdie(
            "Couldn't copy '$csv_file_saved' to '$csv_saved_target'"
        );
    return $csv_saved_target->stringify;
}

sub save_csv_file {
    my $self = shift;
    
    $self->csv_file->move(path($self->csv_save_dir, $self->csv_file->basename))
        or $self->log->logdie( "Couldn't move '" . $self->csv_file . "' to '"
                               . $self->csv_save_dir . "'" );
}


sub start_digifooter {
    my $self = shift;
    
    my $log = $self->log;
    my %init_arg = (
        image_path      => $self->image_path->stringify,
        title           => $self->order->titel->titel_isbd || '',
        author          => $self->order->titel->autor_avs || '',
        configfile      => $self->remedi_configfile,
        source_pdf_file => $self->source_pdf_file
                           && $self->source_pdf_file->stringify,
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
    $log->logdie('Instance can not get_dest_format')
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
        $log->info('OCR files found');
    }
    else { $log->info('No OCR files found'); }
    
    my %init_arg = ( 
        image_path   => $self->image_path->stringify,
        bv_nr        => $self->order->titel->bvnr,
        title        => $self->order->titel->titel_isbd,
        configfile   => $self->remedi_configfile,
        usetypes     => $usetypes,
        is_thesis_workflow => $self->is_thesis_workflow,
    );
    $init_arg{shelf_number}
        =  $self->order->titel->signatur if $self->order->titel->signatur;
    $init_arg{author}
        =  $self->order->titel->autor_avs if $self->order->titel->autor_avs;
    $init_arg{year_of_publication}
        =  $self->order->titel->erschjahr if $self->order->titel->erschjahr;    
    
    Remedi::METS->new_with_config(%init_arg)->make_mets;
    
}


sub start_csv {
    my $self = shift;
    
    my %init_arg = (
        image_path => $self->image_path->stringify,
        configfile => $self->remedi_configfile,
        source_pdf_file => $self->source_pdf_file && $self->source_pdf_file->stringify,
    );
    Remedi::CSV->new_with_config(%init_arg)->make_csv;     
}

sub run {
    my $self = shift;
    
    my $log_msg = $self->prepare_working_dir() if $self->does_copy_files;
    my $log = $self->log;
    $log->info('Program started');
    $log->info($log_msg) if $log_msg;
    $self->order->update({status_id => 22});
    if ($self->does_copy_files) {
        $log->trace('Does copy files');    
        $self->copy_scanfiles();
        $self->copy_pdf()
            if $self->has_source_format and $self->source_format eq 'PDF';
        $self->copy_ocrfiles();
    }

    if ($self->does_digifooter) {
        $log->trace('Does digifooter');
        $self->start_digifooter();
    }

    if ($self->does_csv) {
        $log->trace('Does csv');
        $self->start_csv();
    }
    
    if ($self->does_mets) {
        $log->trace('Does mets');
        $self->start_mets();
    }

    $self->order->update({status_id => 26});    
}

1;
