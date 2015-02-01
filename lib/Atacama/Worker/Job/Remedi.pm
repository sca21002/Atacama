use utf8;
package Atacama::Worker::Job::Remedi;

# ABSTRACT: Job for preparing image and other files for the ingest

use Atacama::Types qw(Bool Dir File Path PDFFile Str);
use Moose;
use MooseX::AttributeShortcuts;
extends 'Atacama::Worker::Job::Base';
use File::Copy qw();
use CAM::PDF;
use Remedi::DigiFooter::App;
use Remedi::METS::App;
use Remedi::CSV::App;
use Data::Dumper;
use Path::Tiny;

sub get_logfile_name {
    my $path = path( Path::Tiny->tempdir, 'worker.log' );
    $path->touchpath;    # doesn't work in one chained instruction, only Win32?? 
    return $path->stringify;
}

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

has 'jpeg2000_list' => (
    is => 'ro',
    isa => Str,
    default => '',
);

has 'jobfiles' => (
    is => 'ro',
    isa => 'ArrayRef[Atacama::Schema::Result::Jobfile]',
    lazy => 1,
    builder => '_build_jobfiles',
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
    isa => PDFFile,
    predicate => 1,
    coerce => 1,
);

around BUILDARGS => sub {
      my $orig  = shift;
      my $class = shift;
      my %args = @_;

      # warn 'BUILDARGS: ' . Dumper(\%args);
      return $class->$orig(@_);
};

sub BUILD {
    my $self = shift;
    
    my $log_msg = $self->prepare_working_dir() if $self->does_copy_files;
    my $log = $self->log;
    $log->info('Worker::Job::Remedi started');
    $log->info($log_msg) if $log_msg;
}

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

sub _build_jobfiles {
    my $self = shift;
    
    my @jobfiles = $self->atacama_schema->resultset('Jobfile')->search(
        { order_id => $self->order_id },
        { order_by => 'filename' },
    )->all;
    $self->log->logcroak('More than one jobfile found in database') 
        if @jobfiles > 1;
    $self->log->logwarn("No jobfile found in database") unless @jobfiles;
    return \@jobfiles;   
}


sub _build_log {
    my $self = shift;
    
    my ($debug_msg, $warn_msg);
    if ( $self->log_config_file->is_file ) {
        Log::Log4perl->init( $self->log_config_file->stringify );
        my $appender = Log::Log4perl->appender_by_name('LOGFILE');
        $appender->file_switch(path($self->working_dir,'remedi.log')->stringify)
            if $appender;
        $debug_msg = sprintf("log config file: '%s'", $self->log_config_file); 
    } else {
        Log::Log4perl->easy_init($Log::Log4perl::INFO);
        $warn_msg = sprintf("log config '%s' not found", $self->log_config_file);
        $warn_msg .= "\nInit easy logging mode";     
    }    
    my $logger = Log::Log4perl->get_logger('Atacama::Worker::Job::Remedi');
    $logger->warn($warn_msg) if $warn_msg;
    $logger->debug($debug_msg) if $debug_msg;
    return $logger;
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

sub copy_jobfiles {
    my $self = shift;

    my $log = $self->log;
    foreach my $jobfile ( @{$self->jobfiles} ) {
        $log->debug("jobfile: " . $jobfile->filename);
        my $source_dir = path($jobfile->filepath);
        my $source = path($source_dir,        $jobfile->filename);
        my $dest   = path($self->working_dir, $jobfile->filename);
        $source->copy($dest)
            or $log->logdie("couldn't copy '$source' to '$dest': $!");
        $log->info("$source --> $dest");
    }    
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

sub clear_working_dir {
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
    $self->clear_working_dir();
    my $csv_file_restored = $self->restore_csv_file if $csv_saved;
    my $log_msg = 'working dir prepared';
    $log_msg .= "\nold CSV file saved as '$csv_file_restored'"
        if $csv_file_restored;
    return $log_msg;
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
        log_level       => $self->log_level,
        title           => $self->order->titel->titel_isbd || '',
        configfile      => $self->remedi_configfile,
    );
    foreach my $key (qw/resolution_correction source_format/) {
        $init_arg{$key} = $self->$key if $self->$key;
    }
    $init_arg{source_pdf_name} = $self->source_pdf_file->stringify
        if $self->source_pdf_file;
    if ($self->jpeg2000_list) {
        $init_arg{jpeg2000list} = $self->jpeg2000_list;  
            # TODO: different notation 
            # jpeg2000list (Remedi) vs. jpeg2000_list (Atacama)
        $init_arg{dest_format_key} = 'list';
            # TODO: Can we simplify this to one argument?
    }
    while (my($key, $val) = each %init_arg) { $log->info("$key => $val") }
    Remedi::DigiFooter::App->new_with_config(%init_arg)->make_footer;
}


sub start_mets {
    my $self = shift;

    my $log = $self->log;
    my $conf = Config::Any->load_files( {
        files => [$self->remedi_configfile],
        use_ext => 1,
    } );
    my ($filename, $config) = %{shift @$conf};
    # TODO move this stuff to Remedi
    my $usetypes = $config->{usetypes} || [qw(archive reference thumbnail)];
    if ( @{$self->ocrfiles} ) {
        push @$usetypes, 'ocr' unless grep { $_ eq 'ocr' } @$usetypes;
        $log->info('OCR files found');
    }
    else { $log->info('No OCR files found'); }
    
    my %init_arg = ( 
        image_path          => $self->image_path->stringify,
        bv_nr               => $self->order->titel->bvnr,
        log_level           => $self->log_level,
        title               => $self->order->titel->titel_isbd,
        configfile          => $self->remedi_configfile,
        usetypes            => $usetypes,
        is_thesis_workflow  => $self->is_thesis_workflow,
    );
    $init_arg{shelf_number}
        =  $self->order->titel->signatur if $self->order->titel->signatur;
    $init_arg{author}
        =  $self->order->titel->autor_avs if $self->order->titel->autor_avs;
    $init_arg{year_of_publication}
        =  $self->order->titel->erschjahr if $self->order->titel->erschjahr;    
    
    Remedi::METS::App->new_with_config(%init_arg)->make_mets;
    
}


sub start_csv {
    my $self = shift;
    
    my %init_arg = (
        image_path => $self->image_path->stringify,
        configfile => $self->remedi_configfile,
        # csv_file => $self->csv_file,           seems not necessary
        log_level  => $self->log_level,
        title => $self->order->titel->titel_isbd,
    );
    $init_arg{source_pdf_file} = $self->source_pdf_file
        if $self->has_source_pdf_file;
    Remedi::CSV::App->new_with_config(%init_arg)->make_csv;     
}

sub run {
    my $self = shift;
   
    my $log = $self->log; 
    $self->order->update({status_id => 22});
    if ($self->does_copy_files) {
        $log->trace('Does copy files');    
        $self->copy_scanfiles();
        $self->copy_pdf()
            if $self->has_source_format and $self->source_format eq 'PDF';
        $self->copy_ocrfiles();
        $self->copy_jobfiles();
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

1; # Magic true value required at end of module
