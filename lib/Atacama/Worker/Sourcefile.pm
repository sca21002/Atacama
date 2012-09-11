package Atacama::Worker::Sourcefile;
use base 'TheSchwartz::Worker';
use Scalar::Util qw(blessed);
use Carp;
use List::Util qw(first);
use MooseX::Types::Path::Class qw(File);
use Remedi::Imagefile;
use Remedi::PDF::API2;
use Data::Dumper;

sub get_sourcefile {
    
    my $entry = shift;
    
    my $log = $job->log;
    my $format = $job->format;
    $log->trace("Format: " . $job->format);    
    $log->trace($entry . " gefunden");
    return if $entry->is_dir;
    # return if $entry->basename lt 'ubr03390'; 
    if ($format eq 'TIFF') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.tif(?:f)?$/i;
        save_scanfile($entry);   
    }
    elsif ($format eq 'JPEG') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.jpg$/i;
        save_scanfile($entry);   
    } 
    elsif ($format eq 'PDF') {
        # skip single page pdfs
        return if $entry->basename =~ /^\w{3,4}\d{5}_\d{3,5}\.pdf$/i;
        return unless $entry->basename =~ /\.pdf$/i;
        save_pdffile($entry)
    }
    else { $log->logcroak("Unbekanntes Format $format"); }
}

sub save_scanfile {
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
    my $pdffile = shift;
    my $clause;
    
    my $log = $job->log;
    my $atacama_schema = $self->atacama_schema;
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
        my $pdf = Remedi::PDF::API2->new(
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
    

sub work {
    my $class = shift;
    my $job_theschwartz = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Remedi';
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work():"
            . " kein Objekt vom Typ TheSchwartz::Job"       
         ) unless blessed($job) && $job->isa( 'TheSchwartz::Job' );
    my $job = Atacama::Worker::Job::Sourcefile->new($job_theschwartz);
    my $log = $self->log;
    $log->info('Programm gestartet');
    $job->order->update({status_id => 22});
    $log->logcroak('Verzeichnis mit Quelldateien nicht gefunden!')
        unless $job->sourcedirs;
    
    foreach  ($job->scanfile_format, 'PDF') {
        $job->format($_);
        $self->log->trace("Start-Format: " . $self->format);
        $job->sourcedir->recurse(
            callback => sub { get_sourcefile(@_) },  # Wow a CodeRef!
            depthfirst => 1,
            preorder => 1
        );
    }

    
    $job->completed();

    $job->order->update({status_id => 27});
    return 1;
};


1;