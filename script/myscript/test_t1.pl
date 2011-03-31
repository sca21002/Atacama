#!/usr/bin/perl
use strict;
use warnings;
use Path::Class;
use List::Util qw(first);

my $order_id = 'ubr06352';
my @source_dirs = (
        '/rzblx8_DATA2/digitalisierung/auftraege/',
        '/rzblx8_DATA3/digitalisierung/auftraege/'
    );
#foreach (@source_dirs) {
#    print Path::Class::Dir->new($_, $order_id), -d Path::Class::Dir->new($_, $order_id) ? 'exist' : 'not exist', "\n";
#}

my $source_dir = first { -d  } map { dir $_, $order_id }  @source_dirs;
print $source_dir , "\n";

