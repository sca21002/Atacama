package Atacama::Worker::Job::Sourcefile;
use Moose;
extends 'Atacama::Worker::Job::Base';
use MooseX::Types::Moose qw(Bool Str);
use MooseX::Types::Path::Class qw(File Dir);
use List::Util qw(first);
use Carp;
use File::Slurp;
use Remedi::Imagefile;
use Remedi::PDF::API2;
use Data::Dumper;
use MooseX::ClassAttribute;


sub get_log_file_name { return  Atacama::Worker::Job::Sourcefile->log_file_name();}
 
has 'prune_dirs' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { ['thumbnails'] },
);


has '+log_config_basename' => (
    default => 'log4perl_sourcefile.conf',
);

class_has '+log_basename' => (
    default => 'sourcefile.log',                        
);

has 'scanfile_formats' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    builder => '_build_scanfile_formats',
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
        '/rzblx8_DATA2/digitalisierung/auftraege/rdiss/',
        '/rzblx8_DATA2/digitalisierung/auftraege/rdiss_2/',
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

sub  _build_scanfile_formats { ['TIFF'] }

sub _build_sourcedir {
    my $self = shift;
    
    return first { -d } map { Path::Class::Dir->new( $_, $self->order_id ) }
        @{$self->sourcedirs}
    ;
}

sub make_get_sourcefile {
    my $self = shift;
    return sub {
        my $entry = shift;
        my $log = $self->log;
        my $format = $self->format;
        $log->trace("Format: $format");    
        $log->trace($entry . " gefunden");
        my $order_id = $self->order_id;
        if ($entry->basename =~ /^\w{3,4}\d{5}/ 
                and $entry->basename !~ /^${order_id}/ 
        ) {
            $log->warn('Datei ' . $entry . ' im falschen Ordner'); 
        }
        return Path::Class::Entity::PRUNE()
            if $entry->is_dir
               and first { $_ eq $entry->basename } @{$self->prune_dirs};
        return if $entry->is_dir;
        if ($format eq 'TIFF') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:tif(?:f)?)/;
            $self->save_scanfile($entry);   
        }
        elsif ($format eq 'JPEG') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:jpg)$/;
            $self->save_scanfile($entry);   
        } 
        elsif ($format eq 'PDF') {
            return unless $entry->basename =~ /^${order_id}.*\.(?i:pdf)$/;
            # skip single page pdfs
            return if $entry->basename =~ /^${order_id}_\d{3,5}\.pdf$/;
            $self->save_pdffile($entry)
        }
        elsif ($format eq 'XML') {
            return unless $entry->basename =~ /^${order_id}_\d{1,5}\.(?i:xml)$/;
            $self->save_ocrfile($entry);
        }     
        else { $log->logcroak("Unbekanntes Format $format"); }
    }
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


sub run {
    my $self = shift;

    my $log = $self->log;
    $log->info('Programm gestartet');

    $self->sourcedir or $log->logcroak('Verzeichnis mit Quelldateien nicht gefunden!');
 
    $log->info('Gesuchte Formate: ' . join(' ',(@{$self->scanfile_formats}, 'PDF', 'XML')));    
    foreach  (@{$self->scanfile_formats}, 'PDF', 'XML') {
        $self->format($_);
        $log->trace("Start-Format: " . $self->format);
        $self->sourcedir->recurse(
            callback => $self->make_get_sourcefile(),            # Wow a closure
            depthfirst => 1,
            preorder   => 1
        );
    }
}



1;
