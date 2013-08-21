#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify;
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use Test::More;

use AtacamaTestSchema;
use Test::WWW::Mechanize::Catalyst;

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

$atacama_schema->resultset('Order')->create({order_id => 'ubr00042'});

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
$mech->get_ok("/order/add");
$mech->content_contains('<title>Auftrag ubr00043 bearbeiten</title>');
$mech->get_ok('/titel/ubr00043/edit');
say $mech->content;

done_testing();