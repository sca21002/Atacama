#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify; 
use Test::More;

use AtacamaTestSchema;
use Test::WWW::Mechanize::Catalyst;

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

my @data;
for (my $i = 1; $i <= 5; $i++) {
    push @data, { order_id => sprintf('ubr%05s', $i) };
}

$atacama_schema->resultset('Order')->populate(\@data);

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'Atacama');
$mech->get_ok("/login");
$mech->submit_form_ok( {
        form_id => 'login_form',
        fields  => {
            username => 'admin',
            password => 'test',
        },
    }, 'login form'
);
$mech->get_ok("/order/ubr00003/edit?navigate=first");
$mech->content_contains('<title>Auftrag ubr00001 bearbeiten</title>');
$mech->get_ok("/order/ubr00003/edit?navigate=next");
$mech->content_contains('<title>Auftrag ubr00004 bearbeiten</title>');
$mech->get_ok("/order/ubr00003/edit?navigate=prev");
$mech->content_contains('<title>Auftrag ubr00002 bearbeiten</title>');
$mech->get_ok("/order/ubr00003/edit?navigate=last");
$mech->content_contains('<title>Auftrag ubr00005 bearbeiten</title>');
$mech->get_ok("/order/ubr00003/edit?navigate=2");
$mech->content_contains('<title>Auftrag ubr00002 bearbeiten</title>');
done_testing();
