#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use Text::CSV_XS;
use Modern::Perl;

my $dir = path('.');
my @files = $dir->children(qr/\.tif$/);
say "Count: ", scalar @files;

#foreach my $file (sort @files) {
#    my ($filestem) = $file->basename =~ /(.*)\.tif$/;
#    say $filestem;
#}

my $csv_file = path('test.csv');

my $csv = Text::CSV_XS->new ({ binary => 1 }) or
    die "Cannot use CSV: ".Text::CSV->error_diag ();

$csv->eol ("\r\n");
$csv->sep_char(";");
open my $fh, ">:encoding(utf8)", $csv_file->stringify
    or die "$csv_file: $!";

foreach my $file (sort @files) {
    my ($filestem) = $file->basename =~ /(.*)\.tif$/;
    my ($count) = $filestem =~ /ubr05510_(.*)$/;
    die "No issue found for $filestem" unless $count; 
    $count = '4650' if $count eq '4659'; 
    my $call_number = 'W 02/K 180/' . $count;
    $call_number =~ s/_/\//;
    $csv->print ($fh, [ $filestem, $call_number ] );
}
close $fh or die "$csv_file: $!"; 
