#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use FindBin qw($Bin);
use Path::Tiny;

my $file_reg = qr/ubr\d{5}_(\d{1,5})\.(tif|TIF)/;

my $dir = path('/mnt/rzblx9/data/digitalisierung/scanner/Einzugscanner/ubr16380/');

my $even_dir = $dir->child('even')->mkpath or die "Couldn't create subdir 'even'";

my @files = sort $dir->children( qr/$file_reg/ );

foreach my $file (@files) {
    say $file->basename;
    my ($count) = $file->basename =~ qr/$file_reg/;
    if ($count % 2  == 0) {
        say "Copy $file->basename";
        $file->copy($even_dir);
    }
}
