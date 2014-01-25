#!/usr/bin/env perl
use utf8;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify,
        path($Bin)->parent(3)->child(qw(Remedi lib))->stringify;

use English qw( -no_match_vars ) ;           # Avoids regex performance penalty
use Getopt::Long;

use Pod::Usage;
use Modern::Perl;
use Atacama::Worker::Job::Sourcefile;
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

my $rootdir = path('/rzblx8_DATA3/digitalisierung/auftraege/');
#my @orderpaths = $rootdir->children( qr/^ubr\d{5}$/ );
my @orderpaths = $rootdir->children( qr/^ubr13808$/ );


for my $orderpath (@orderpaths) {
    my $job = Atacama::Worker::Job::Sourcefile->new({
        order_id         => $orderpath->basename,
        sourceformats => ['TIFF', 'XML'],
        sourcedirs       => ['/rzblx8_DATA3/digitalisierung/auftraege/']
    });
    $job->run;
}
