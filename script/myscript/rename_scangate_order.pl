#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify; 
use Log::Log4perl qw(:easy);
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

my $order_id = 'ubr18281';

my $base_dir = path('/mnt/rzblx9/data/scanflow/final');
LOGDIE "$base_dir not found" unless $base_dir->is_dir;  
my $order_dir = $base_dir->child($order_id);
LOGDIE "$order_dir not found" unless $order_dir->is_dir;  

my $iter = $order_dir->iterator( {
    recurse => 1,
} );

while ( my $path = $iter->() ) {
    next unless $path->is_file; 
    my $basename = $path->basename;
    next if $basename =~/\A$order_id/;
    $basename =~ s/\Aubr\d{5}/$order_id/
        or LOGWARN "no substitution for $path";  
    $path->move($path->parent->child($basename)) 
        or LOGWARN "Couldn't rename $path!";
    say "$path --> ", $path->parent->child($basename);
}
