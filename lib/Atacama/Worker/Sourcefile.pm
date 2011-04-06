package Atacama::Worker::Sourcefile;
use strict;
use warnings;
use base 'TheSchwartz::Worker';
use Scalar::Util qw(blessed);
use Carp;
use Log::Log4perl;
use List::Util qw(first);
use Data::Dumper;
use Path::Class;
use Remedi::Imagefile;
use Remedi::PDF_API2;

my $log_file_name;
my $log;
my $atacama_schema;
my $format;


sub work {
    my $class = shift;
    my $job = shift;


    my @sourcedirs = (
        '/rzblx8_DATA2/digitalisierung/auftraege/',
        '/rzblx8_DATA3/digitalisierung/auftraege/'
    );
    croak('Falscher Aufruf von ',__PACKAGE__ ,"::work() mit Klasse: $class")
        unless $class eq __PACKAGE__;
    croak('Falscher Aufruf von ',__PACKAGE__ ,'::work():'
            . ' kein Objekt vom Typ TheSchwartz::Job')
        unless blessed($job) && $job->isa( 'TheSchwartz::Job' );
    my $arg = $job->arg or croak("Keine Job-Parameter gefunden");
    my $order_id = $arg->{order_id} or croak("Keine Auftragsnummer");
    my $log_file_name = File::Spec->catfile(
        $FindBin::Bin, '..', 'log', 'sourcefile_' . $order_id
    ); 
    unlink $log_file_name if -e $log_file_name;
    my $log_configfile = File::Spec->catfile(
        $FindBin::Bin, '..', 'log4perl_sourcefile.conf'
    );
    Log::Log4perl->init($log_configfile);
    $log = Log::Log4perl->get_logger('Atacama::Worker::Sourcefile');
    $log->info('Programm gestartet');        
    my $atacama_config = get_atacama_config()
      or $log->logcroak("Lesen der Atacama-Konfigurationsdatei fehlgeschlagen");       
    my $sourcedir
        = first { -d } map {Path::Class::Dir->new($_, $order_id) } @sourcedirs
            or $log->logcroak('Verzeichnis mit Quelldateien nicht gefunden!');
    my @dbic_connect_info
        = @{ $atacama_config->{'Model::AtacamaDB'}{connect_info} };
    $atacama_schema = Atacama::Schema->connect(@dbic_connect_info)
        or $log->logcroak("Datenbankverbindung gescheitert");    
    
    foreach  ('TIFF', 'PDF') {
        $format = $_;
        $log->trace("Start-Format: " . $format);
        $sourcedir->recurse(
            callback => \&get_sourcefile,
            depthfirst => 1,
            preorder => 1
        );
    }
    
    $job->completed();
}

sub get_logfile_name { $log_file_name }

sub get_sourcefile {
    my $entry = shift;
    $log->trace("Format: " . $format);    
    $log->trace($entry . " gefunden");
    return if $entry->is_dir;
    # return if $entry->basename lt 'ubr03390'; 
    if ($format eq 'TIFF') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.tif(?:f)?$/;
        save_scanfile($entry);   
    } 
    elsif ($format eq 'PDF') {
        return unless $entry->basename =~ /\.(pdf)$/;
        save_pdffile($entry)
    }
    else { $log->logcroak("Unbekanntes Format $format"); }
}


sub save_scanfile{
    my $scanfile = shift;
    my $clause;
    
    $log->info($scanfile);
    eval {
        my $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => qr/\w{3,4}\d{5}/,
            file => $scanfile,
        );
        $clause->{filename}     = $image->basename;
        $clause->{filepath}     = $image->dir->stringify;
        $clause->{order_id}     = $image->order_id;
        $clause->{format}       = $image->format;
        $clause->{colortype}    = $image->colortype;
        $clause->{resolution}   = $image->resolution;
        $clause->{height_px}    = $image->height_px;
        $clause->{width_px}     = $image->width_px;
        $clause->{filesize}     = $image->size;
        $clause->{icc_profile}  = $image->icc_profile
            if $image->colortype eq 'color';
        $clause->{md5}          = $image->md5_checksum->hexdigest;
        $log->trace("Imagefile: " . Dumper($clause));
    };
    unless ($@) {
        $atacama_schema->resultset('Scanfile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $scanfile nicht verarbeiten: $@");
        $atacama_schema->resultset('Scanfile')->update_or_create({
            filename => $scanfile->basename,
            filepath => $scanfile->dir->stringify,
            error    => $@,
        });
    }
}

sub save_pdffile{
    my $pdffile = shift;
    my $clause;
    
    $log->info("PDF-Datei: $pdffile");
    eval {
        my $index = -1;
        my $order_id;
        while (!$order_id and $index >= -3) {
            ($order_id) = (File::Spec->splitdir($pdffile->dir))[$index--]
                =~ /^((?:u|s)br\d{5})/i;
        }
        $log->debug("Keine Auftragsnummer gefunden fuer $pdffile") unless $order_id;
        $order_id = lc $order_id;
        my $pdf = Remedi::PDF_API2->new(
            file => $pdffile,
        );
        $clause->{order_id} = $order_id;
        if ($order_id) {
            $clause->{filename} = $pdffile->basename;
            $clause->{filepath} = $pdffile->dir->stringify;;
            # $clause->{ocr}    = $ocr;
            $clause->{pages}    = $pdf->pages;
            $clause->{filesize} = $pdf->size;
        }
        $pdf->release();
        $log->trace("PDF-Datei: " . Dumper($clause));    
    };
    return unless $clause->{order_id};
    unless ($@) {
        $atacama_schema->resultset('Pdffile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $pdffile nicht verarbeiten: $@");
        $atacama_schema->resultset('Pdffile')->update_or_create({
            filename => $pdffile->basename,
            filepath => $pdffile->dir->stringify,
            error    => $@,
        });
    }
}

sub get_atacama_config {
   
    my $config = Config::ZOMG->new(
        name => 'Atacama',
        path => File::Spec->catfile($FindBin::Bin, '..'),
    );
    return $config->load;    
}


1;
