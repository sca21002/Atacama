package Atacama::Worker::Sourcefile;
use Moose;
extends 'Atacama::Worker::Base';
use List::Util qw(first);
use MooseX::Types::Path::Class qw(File);
use Remedi::Imagefile;
use Remedi::PDF::API2;
use Data::Dumper;

has '+log_config_basename' => (
    default => 'log4perl_sourcefile.conf',
);

has '+log_basename' => (
    default => 'sourcefile.log',                        
);

has 'scanfile_format' => (
    is => 'rw',
    isa => 'Str',
    builder => '_build_scanfile_format',
    lazy => 1,
);    


has 'format' => (
    is => 'rw',
    isa => 'Str',
);
    


has  'sourcedirs' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [                  
        '/rzblx8_DATA1/digitalisierung/auftraege/',
        '/rzblx8_DATA2/digitalisierung/auftraege/',
        '/rzblx8_DATA3/digitalisierung/auftraege/',
        '/mnt/rzblx9/data/digitalisierung/auftraege/',
    ] },
);

has 'sourcedir' => (
    is => 'rw',
    isa => 'Maybe[Path::Class::Dir]',
    builder => '_build_sourcedir',
    lazy => 1,
);
    
sub  _build_scanfile_format {
    my $self = shift;    
    
    return $self->job->arg->{scanfile_format} || 'TIFF';
}

sub _build_sourcedir {
    my $self = shift;
    
    return first { -d } map { Path::Class::Dir->new( $_, $self->order_id ) }
        @{$self->sourcedirs}
    ;

}

sub get_sourcefile {
    
    my $self = shift;
    my $entry = shift;
    
    my $log = $self->log;
    my $format = $self->format;
    $log->trace("Format: " . $self->format);    
    $log->trace($entry . " gefunden");
    return if $entry->is_dir;
    # return if $entry->basename lt 'ubr03390'; 
    if ($format eq 'TIFF') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.tif(?:f)?$/i;
        $self->save_scanfile($entry);   
    }
    elsif ($format eq 'JPEG') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.jpg$/i;
        $self->save_scanfile($entry);   
    } 
    elsif ($format eq 'PDF') {
        # skip single page pdfs
        return if $entry->basename =~ /^\w{3,4}\d{5}_\d{3,5}\.pdf$/i;
        return unless $entry->basename =~ /\.pdf$/i;
        $self->save_pdffile($entry)
    }
    else { $log->logcroak("Unbekanntes Format $format"); }
}

sub save_scanfile {
    my $self = shift;
    my $scanfile = shift;
    my $clause;
    
    my $log = $self->log;
    my $atacama_schema = $self->atacama_schema;
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
    my $self = shift;
    my $pdffile = shift;
    my $clause;
    
    my $log = $self->log;
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
    

around 'work' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $result = $self->$orig(@_);
    my $log = $self->log;
    $log->info('Programm gestartet');
    $self->order->update({status_id => 22});
    $log->logcroak('Verzeichnis mit Quelldateien nicht gefunden!')
        unless $self->sourcedirs;
    
    foreach  ($self->scanfile_format, 'PDF') {
        $self->format($_);
        $self->log->trace("Start-Format: " . $self->format);
        $self->sourcedir->recurse(
            callback => sub { $self->get_sourcefile(@_) },  # Wow a CodeRef!
            depthfirst => 1,
            preorder => 1
        );
    }

    
    $self->job->completed();

    $self->order->update({status_id => 27});
    return 1;
};


1;