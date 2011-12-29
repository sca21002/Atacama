#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../Remedi-0.04/lib", "$FindBin::Bin/../lib";
use Data::Dumper;
use Path::Class;
use  Log::Log4perl qw(:easy);
use Getopt::Long;
use Remedi::ImageMagickCmds;
use feature qw(say);
use PDF::API2;

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . Path::Class::File->new(
                           $FindBin::Bin, '..', '..', 'log', 'create_pdf_from_tiffs.log'
                       ),
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

my $resolution = 300;  # 300 dpi
my $outdir = 'D:\Albert\out';

my @dirs;
GetOptions (
    "dir=s"    => \@dirs,
    "resolution=s" => \$resolution,
    "out=s"    => \$outdir,
);

my @sourcefile_dirs;
foreach my $dir (@dirs) {
    LOGDIE("Verzeichnis " . $dir . "nicht gefunden") unless -e $dir;
    push @sourcefile_dirs, Path::Class::Dir->new($dir);    
}

mkdir( $outdir, 0755 ) unless -e $outdir;


my $cnt = 0;

my $pdf=PDF::API2->new;

foreach my $sourcefile_dir (@sourcefile_dirs) {
    my $no_file = 1;
    my (undef, $directories, undef) = File::Spec->splitpath($sourcefile_dir, $no_file);
    TRACE('Directory part of sourcefile_dir ' . $directories);
    my @dirs = File::Spec->splitdir($directories);
    TRACE('Last portion of sourcefile_dir ' . $dirs[-1]);
    $outdir = dir($outdir, $dirs[-1] . '_' . $resolution . 'dpi');
    INFO("Ausgabeverzeichnis " . $outdir);
    mkdir( $outdir, 0755 ) unless -e $outdir;
    INFO($sourcefile_dir . " und alle Unterverzeichnisse werden durchsucht ...");
    $sourcefile_dir->recurse(
        callback => \&get_sourcefile,
        depthfirst => 1,
        preorder => 1
    );
    my $pdf_filename = file($outdir, $dirs[-1] . '.pdf');
    INFO("Schreibe PDF $pdf_filename"); 
    $pdf->saveas($pdf_filename->stringify);
}

sub get_sourcefile {
    my $entry = shift;
    
    TRACE($entry . " gefunden");
    say $entry;


    return if $entry->is_dir;
    return unless $entry->basename =~ /\.JPG$/i;
    $cnt++;
#    return if $cnt > 2;
    my $outfile_basename = $entry->basename;
    $outfile_basename =~ s/\.JPG$/\.tif/i;
    my $outfile = file($outdir, $outfile_basename); 
    Remedi::ImageMagickCmds::convert_to_tiff_g4_with_resample(
        $entry->stringify,
        $outfile->stringify,
        $resolution
    );
    my $img = $pdf->image_tiff($outfile->stringify);
    my $page = $pdf->page;
    $page->mediabox($img->width,$img->height);
    my $gfx=$page->gfx;
    $gfx->image($img,0,0,1);
}
