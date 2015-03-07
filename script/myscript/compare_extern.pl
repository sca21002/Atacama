#!/usr/bin/perl
use strict;
use warnings;
use Modern::Perl;

use Path::Tiny;

my $vol1 = path('E:/digitalisierung');
my $vol2 = path('F:/digitalisierung');

my %seen;

my @double1;
my @only2;
my $iter;

$iter = path($vol1)->iterator({recurse => 1});
while ( my $path = $iter->() ) {
    next unless $path->is_file;
    say $path;
    if ($seen{$path->basename}) {
        push @double1, $path, $seen{$path->basename}
    } else {    
        $seen{$path->basename} = $path;
    }
}

$iter = path($vol2)->iterator({recurse => 1});
while ( my $path = $iter->() ) {
    next unless $path->is_file;
    say $path;
    unless ($seen{$path->basename}) {
        push @only2, $path;
    } else {
        delete $seen{$path->basename};
    }
}

say "Double 1:";

say join "\n", @double1;

say "Only2:";

say join "\n", @only2;

say "Only 1:";

foreach my $basename (keys %seen ) {
    say $seen{$basename};    
}
