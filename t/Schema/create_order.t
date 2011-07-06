#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use utf8;
binmode(STDOUT, ":utf8");

use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin,'..','lib');
use lib File::Spec->catfile($FindBin::Bin,'..','..','lib');
use_ok( 'AtacamaTestSchema' );
# use_ok('DBIx::Class::ResultClass::HashRefInflator');
use Data::Dumper;

ok( my $schema = AtacamaTestSchema->init_schema(populate => 1), 'created a test schema object' );
ok(my $order_rs = $schema->resultset('Order'), 'Resultset Order');
ok(my $order = $order_rs->find('ubr02862'),'find order ubr02862');

ok($order = $order_rs->create_order(
    {order_id => 'ubr02863'}
),'create new order ubr02863');
is($order->order_id, 'ubr02863', 'order_id ubr02863');
is(DateTime->now(
        locale      => 'de_DE',
        time_zone   => 'Europe/Berlin',
    )->day,
    $order->creation_date->day, 'creation date (day)');

ok($order = $order_rs->create_order(
    {}
),'create new order with next free order number');
is($order->order_id, 'ubr02864', 'order_id ubr02864');
is(DateTime->now(
        locale      => 'de_DE',
        time_zone   => 'Europe/Berlin',
    )->day,
    $order->creation_date->day, 'creation date (day)');

ok($order = $order_rs->create_order(
    {status_id => 9}
),'create new order with status = veröffentlicht');
is($order->order_id, 'ubr02865', 'order_id ubr02865');
is($order->status->name, 'veröffentlicht', 'Status veröffentlicht');

ok($order = $order_rs->create_order({
    titel => {
        titel_avs => 'Deutsche Ofenplatten',
        autor_avs => 'Schröder, Albert',
        verlag => 'Leipzig',
        signatur => '999/Art.533',
    }, 
}), 'create new order with title');                                
is ($order->titel->titel_isbd,
    'Schröder, Albert : Deutsche Ofenplatten. - Leipzig','titel');

done_testing();