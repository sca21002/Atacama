#!/usr/bin/env perl
use utf8;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Atacama::Helper;
use Modern::Perl;

my $schema = Atacama::Helper::get_schema(path($Bin)->parent(2));

my $order = $schema->resultset('Order')->find({ 
    order_id => 'ubr03883',
});

$order->update({status_id => 9});



