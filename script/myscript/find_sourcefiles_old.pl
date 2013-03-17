#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../Remedi/lib", "$FindBin::Bin/../../lib";
use Data::Dumper;
use Path::Class;
use File::Slurp;
# use Perl6::Say;
use feature qw(say);
use Config::Any;
use  Log::Log4perl qw(:easy);
use Atacama::Schema;
use Getopt::Long;
use Remedi::Imagefile;
use Remedi::PDF::API2;
use Digest::MD5;

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . Path::Class::File->new(
                           $FindBin::Bin, '..', '..', 'log', 'find_sourcefiles.log'
                       ),
    },
    { level   => $DEBUG,
      file    => 'STDOUT',
    },
);

my $format = 'TIFF'; 

my @dirs;
GetOptions (
    "dir=s"    => \@dirs,
    "format=s" => \$format, 
);

LOGDIE("Unbekanntes Formate $format") unless $format =~ /TIFF|PDF|JPG|XML/i; 
$format = uc $format;

INFO("Parameter: ", join(' ',@dirs));

my @sourcefile_dirs;
foreach my $dir (@dirs) {
    LOGDIE("Verzeichnis " . $dir . "nicht gefunden") unless -e $dir;
    push @sourcefile_dirs, Path::Class::Dir->new($dir);    
}

### Konfiguration einlesen
my $conf = Config::Any->load_stems({
    stems => [ Path::Class::File->new( $FindBin::Bin, '..', '..', 'atacama_local') ],
    use_ext => 1,
});

my ($filename, $config) = %{shift @$conf};
TRACE("Konfigurationsdatei " .  $filename . " gelesen");

### Datenbankverbindung
my @connect_info = @{ $config->{'Model::AtacamaDB'}{connect_info} };
LOGFATAL("Verbindungsparamter(connect_info) für die Datenbank nicht gefunden")
    unless @connect_info;
my $schema_atacama = Atacama::Schema->connect(@connect_info);

foreach my $sourcefile_dir (@sourcefile_dirs) {
    INFO($sourcefile_dir . " und alle Unterverzeichnisse werden durchsucht ...");        
    $sourcefile_dir->recurse(
        callback => \&get_sourcefile,
        depthfirst => 1,
        preorder => 1
    ); 
}

sub get_sourcefile {
    my $entry = shift;
    
    TRACE($entry . " gefunden");
    return Path::Class::Entity::PRUNE() if $entry->is_dir and $entry->basename eq 'thumbnails';
    return if $entry->is_dir;
    #return if $entry->basename lt 'ubr11967'; 
    if ($format eq 'TIFF') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.tif(?:f)?$/;
        save_scanfile($entry);   
    } 
    elsif ($format eq 'PDF') {
        return unless $entry->basename =~ /\.pdf$/;
        # skip single page pdfs
        return if $entry->basename =~ /^\w{3,4}\d{5}_\d{3,5}\.pdf$/i;
        save_pdffile($entry)
    }
    elsif ($format eq 'JPG') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.(?:JPG|jpg)$/;
        save_scanfile($entry);
    }
    elsif ($format eq 'XML') {
        return unless $entry->basename =~ /^\w{3,4}\d{5}_\d{1,5}\.xml$/;
        save_ocrfile($entry);
    }     
    else { LOGDIE("Unbekanntes Format $format"); }
}


sub save_scanfile{
    my $scanfile = shift;
    my $clause;
    
    INFO($scanfile);
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
        TRACE("Imagefile: " . Dumper($clause));
    };
    unless ($@) {
        $schema_atacama->resultset('Scanfile')->update_or_create($clause);
    } else {
        LOGWARN("Konnte $scanfile nicht verarbeiten: $@");
        $schema_atacama->resultset('Scanfile')->update_or_create({
            filename => $scanfile->basename,
            filepath => $scanfile->dir->stringify,
            error    => $@,
        });
    }
}

sub save_pdffile{
    my $pdffile = shift;
    my $clause;
    
    INFO("PDF-Datei: $pdffile");
    eval {
        my $index = -1;
        my $order_id;
        while (!$order_id and $index >= -3) {
            ($order_id) = (File::Spec->splitdir($pdffile->dir))[$index--]
                =~ /^((?:u|s)br\d{5})/i;
        }
        DEBUG("Keine Auftragsnummer gefunden fuer $pdffile") unless $order_id;
        $order_id = lc $order_id;
        my $pdf = Remedi::PDF::API2->open(
            file => $pdffile,
        );
        DEBUG("PDF-Dateiname: " .  $pdffile->basename);
        $clause->{order_id} = $order_id;
        if ($order_id) {
            $clause->{filename} = $pdffile->basename;
            $clause->{filepath} = $pdffile->dir->stringify;;
            # $clause->{ocr}    = $ocr;
            $clause->{pages}    = $pdf->pages;
            $clause->{filesize} = $pdf->size;
        }
        $pdf->release();
        TRACE("PDF-Datei: " . Dumper($clause));    
    };
    my $order_id = $clause->{order_id};
    return unless $clause->{order_id};
    return if $clause->{filename} =~ /^ubr10365_\d{2,5}\.pdf/;
    unless ($@) {
        $schema_atacama->resultset('Pdffile')->update_or_create($clause);
        DEBUG("Datei " .  $clause->{filename} . " in der Datenbank gespeichert");
    } else {
        LOGWARN("Konnte $pdffile nicht verarbeiten: $@");
        $schema_atacama->resultset('Pdffile')->update_or_create({
            filename => $pdffile->basename,
            filepath => $pdffile->dir->stringify,
            error    => $@,
        });
    }
}

sub save_ocrfile {
    my $ocrfile = shift;
    my $clause;
    
    INFO("OCR-Datei: $ocrfile");
    eval {
        ($clause->{order_id}) = $ocrfile->basename =~ /^(\w{3,4}\d{5})_\d{1,5}\.xml$/;    
        $clause->{filename} = $ocrfile->basename;
        $clause->{filepath} = $ocrfile->dir->stringify;;
        $clause->{filesize} = -s $ocrfile;
        $clause->{format} = 'XML';
        my $md5 = Digest::MD5->new;
        my $bin_data = read_file( $ocrfile, binmode => ':raw' ) ;    
        $clause->{md5} = $md5->add($bin_data)->hexdigest;
        TRACE("OCR-file: " . Dumper($clause));

    };
    unless ($@) {
        $schema_atacama->resultset('Ocrfile')->update_or_create($clause);
    } else {
        LOGWARN("Konnte $ocrfile nicht verarbeiten: $@");
        $schema_atacama->resultset('Ocrfile')->update_or_create({
            filename => $ocrfile->basename,
            filepath => $ocrfile->dir->stringify,
            error    => $@,
        });
    }    
}
