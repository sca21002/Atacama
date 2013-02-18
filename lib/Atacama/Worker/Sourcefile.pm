package Atacama::Worker::Sourcefile;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Sourcefile;
use MooseX::Types::Path::Class qw(File);
use Scalar::Util qw(blessed);
use Carp;
use Remedi::Imagefile;
use Remedi::PDF::API2;
use File::Slurp;
use Data::Dumper;

my $log_file_name;

sub get_logfile_name { $log_file_name }

sub make_get_sourcefile {
    my $job = shift;
    return sub {
        my $entry = shift;
        my $log = $job->log;
        my $format = $job->format;
        $log->trace("Format: " . $job->format);    
        $log->trace($entry . " gefunden");
        my $order_id = $job->order_id;
        if ($entry->basename =~ /^\w{3,4}\d{5}/ 
                and $entry->basename !~ /^${order_id}/ 
        ) {
            $log->warn('Datei ' . $entry . ' im falschen Ordner'); 
        }
        return Path::Class::Entity::PRUNE()
            if $entry->is_dir and $entry->basename eq 'thumbnails';
        return if $entry->is_dir;
        if ($format eq 'TIFF') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:tif(?:f)?)/;
            save_scanfile($job, $entry);   
        }
        elsif ($format eq 'JPEG') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:jpg)$/;
            save_scanfile($job, $entry);   
        } 
        elsif ($format eq 'PDF') {
            return unless $entry->basename =~ /^${order_id}.*\.(?i:pdf)$/;
            # skip single page pdfs
            return if $entry->basename =~ /^${order_id}_\d{3,5}\.pdf$/;
            save_pdffile($job, $entry)
        }
        elsif ($format eq 'XML') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:xml)$/;
            save_ocrfile($job, $entry);
        }     
        else { $log->logcroak("Unbekanntes Format $format"); }
    }
}

sub save_scanfile {
    my $job = shift;
    my $scanfile = shift;
    my $clause;
    
    my $log = $job->log;
    my $atacama_schema = $job->atacama_schema;
    $log->info('Scanfile: ' . $scanfile);
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
    my $job = shift;
    my $pdffile = shift;
    my $clause;
    
    my $log = $job->log;
    my $atacama_schema = $job->atacama_schema;
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
        my $pdf = Remedi::PDF::API2->open(
            file => $pdffile,
        );
        $clause->{order_id} = $order_id;
        if ($order_id) {
            $clause->{filename} = $pdffile->basename;
            $clause->{filepath} = $pdffile->dir->stringify;;
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
    
sub save_ocrfile {
    my $job = shift;
    my $ocrfile = shift;
    my $clause;
    
    my $log = $job->log;
    my $atacama_schema = $job->atacama_schema;
    $log->info("OCR-Datei: $ocrfile");
    eval {
        ($clause->{order_id}) = $ocrfile->basename =~ /^(\w{3,4}\d{5})_\d{1,5}\.xml$/;    
        $clause->{filename} = $ocrfile->basename;
        $clause->{filepath} = $ocrfile->dir->stringify;;
        $clause->{filesize} = -s $ocrfile;
        $clause->{format} = 'XML';
        my $md5 = Digest::MD5->new;
        my $bin_data = read_file( $ocrfile, binmode => ':raw' ) ;    
        $clause->{md5} = $md5->add($bin_data)->hexdigest;
        $log->trace("OCR-file: " . Dumper($clause));
    };
    unless ($@) {
        $atacama_schema->resultset('Ocrfile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $ocrfile nicht verarbeiten: $@");
        $atacama_schema->resultset('Ocrfile')->update_or_create({
            filename => $ocrfile->basename,
            filepath => $ocrfile->dir->stringify,
            error    => $@,
        });
    }    
}

sub work {
    my $class = shift;
    my $job_theschwartz = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Sourcefile';
    $job = Atacama::Worker::Job::Sourcefile->new(job => $job_theschwartz);
    $log_file_name = $job->log_file_name;
    my $log = $job->log;
    $log->info('Programm gestartet');
    $job->order->update({status_id => 23});
    $job->sourcedir or $log->logcroak('Verzeichnis mit Quelldateien nicht gefunden!');
 
    
    foreach  ($job->scanfile_format, 'PDF', 'XML') {
        $job->format($_);
        $job->log->trace("Start-Format: " . $job->format);
        $job->sourcedir->recurse(
            callback => make_get_sourcefile( $job ),  # Wow a Closure!
            depthfirst => 1,
            preorder => 1
        );
    }

    
    $job->completed();

    $job->order->update({status_id => 27});
    return 1;
};




1;
