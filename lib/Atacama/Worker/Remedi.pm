package Atacama::Worker::Remedi;

#use Moose;
use base 'TheSchwartz::Worker';
use Scalar::Util qw(blessed);
use Atacama::Schema;
use Remedi::DigiFooter;
use Remedi::Mets;
use Remedi::CSV;
use Log::Log4perl;
use Path::Class;
use Data::Dumper;
use File::Spec;
use File::Copy;
use Carp;
use Config::ZOMG;
use CAM::PDF;

my $log_file_name;

sub work {
    my $class = shift;
    my $job = shift;

    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Remedi';
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work():"
            . " kein Objekt vom Typ TheSchwartz::Job"       
         ) unless blessed($job) && $job->isa( 'TheSchwartz::Job' );
    my $arg = $job->arg or croak ("Keine Job-Parameter gefunden");
    my $atacama_config = get_atacama_config()
        or croak ("Lesen der Atacama-Konfigurationsdatei fehlgeschlagen");   
    my $order_id = $arg->{order_id} or croak ("Keine Auftragsnummer");
    my $work_dir = $atacama_config->{'Atacama::Worker::Remedi'}{work_dir}
        or croak("Kein Arbeitsverzeichnis"); 
    my $workdir = Path::Class::Dir->new($work_dir, $order_id);
    $workdir->mkpath() or croak("Konnte Arbeitsverzeichnis $workdir nicht anlegen")
	unless -e $workdir;
    $log_file_name = File::Spec->catfile($workdir, 'remedi.log');
    unlink $log_file_name if -e $log_file_name;
    my $remedi_configfile = $arg->{configfile}
        or croak("Keine Remedi-Konfigurationsdatei");
    my $source_pdf_name = $arg->{source_pdf_name};
    my $log_configfile = File::Spec->catfile(
        $FindBin::Bin, '..', 'log4perl.conf'
    );
    Log::Log4perl->init($log_configfile);
    my $log = Log::Log4perl->get_logger('Atacama::Worker::Remedi');
    $log->info('Programm gestartet');
    while (my($key, $val) = each %$arg) { $log->info("$key => $val") } 
    
    my @dbic_connect_info
        = @{ $atacama_config->{'Model::AtacamaDB'}{connect_info} };
    my $atacama_schema = Atacama::Schema->connect(@dbic_connect_info)
        or $log->logcroak("Datenbankverbindung gescheitert");
    
    my $order = $atacama_schema->resultset('Order')->find($order_id);
    $order->update({status_id => 22});

    my $remedi_config = get_remedi_config($remedi_configfile)
        or $log->logcroak("Lesen der Remedi-Konfiguration fehlgeschlagen"); 
    my @scanfiles = $atacama_schema->resultset('Scanfile')->search(
        { order_id => $order_id },
        { order_by => 'filename' },
    )->all;
    $log->logcroak("Keine Scandateien in der Datenbank") unless (@scanfiles);
    if ($arg->{copy_files}) {
        foreach my $scanfile (@scanfiles) {
            $log->debug("Scandatei: " . $scanfile->filename);
            my $sourcedir = $scanfile->filepath;
            my $source = File::Spec->catfile($sourcedir, $scanfile->filename);
            my $dest   = File::Spec->catfile($workdir,   $scanfile->filename);
            copy($source, $dest) 
                or $log->logdie("Konnte $source nicht nach $dest kopieren: $!");
            $log->info("$source --> $dest");
        }
        if ( $arg->{source_format} eq 'PDF' ) {
            my $source = Path::Class::File->new( $arg->{source_pdf_name} );
            my $dest   = Path::Class::File->new($workdir, $order_id . '.pdf');  
            if ($source->basename =~ /^UBR\d{2}A\d{6}\.pdf/) {
                $log->info("EOD-PDF: " . $source);
		my $doc = CAM::PDF->new($source) || $log->logdie("$CAM::PDF::errstr\n");
                my $pagenums = '1-4,' . $doc->numPages;
                if (!$doc->deletePages($pagenums)) {
		    $log->logdiei("Failed to delete a page\n");
		}
		$doc->cleanoutput($dest);
	    }
	    else {
		copy($source, $dest) 
                or $log->logdie("Konnte $source nicht nach $dest kopieren: $!");
	    }
	    $source_pdf_name = $dest->stringify;  # spaeter API aendern Path::Class		
            $log->info("$source --> $dest");
        }
    }
    my $titel = $order->titel;
    my %init_arg;
    if ($arg->{digifooter}) {
        %init_arg = (
            image_path => $order_id,
            title      => $titel->titel_isbd,
            author     => $titel->autor_avs,
            configfile => $remedi_configfile,
	    source_pdf_name => $source_pdf_name,
        );
        foreach my $key (qw/resolution_correction source_format/) {
            $init_arg{$key} = $arg->{$key} if $arg->{$key};
        }
        while (my($key, $val) = each %init_arg) { $log->info("$key => $val") } 
        Remedi::DigiFooter->new_with_config(%init_arg)->make_footer;
    }
    if ($arg->{mets}) {    
        %init_arg = ( 
            image_path   => $order_id,
            bv_nr        => $titel->bvnr,
            shelf_number => $titel->signatur,
            title        => $titel->titel_isbd,
            author       => $titel->autor_avs,
            configfile   => $remedi_configfile,
        );
        Remedi::Mets->new_with_config(%init_arg)->make_mets;
    }
    if ($arg->{csv}) {        
        %init_arg = (
            image_path => $order_id,
            configfile => $remedi_configfile,
        );
        Remedi::CSV->new_with_config(%init_arg)->make_csv; 
    }
    $job->completed();
    $order->update({status_id => 12});
}

sub get_logfile_name { $log_file_name }


sub get_atacama_config {
   
    my $config = Config::ZOMG->new(
        name => 'Atacama',
        path => File::Spec->catfile($FindBin::Bin, '..'),
    );
    return $config->load;    
}

sub get_remedi_config {
    my $remedi_configfile = shift;
    
    my $conf = Config::Any->load_files({
        files => [ $remedi_configfile ],
        use_ext => 1,
    });
    my ($filename, $remedi_config) = %{shift @$conf};
    return $remedi_config;
}



1;
