#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify;

use Test::More;
use Test::WWW::Mechanize::Catalyst;
use AtacamaTestSchema;

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

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
$mech->get_ok("/titel/json?signatur=999/Art.533");
my $str = 'Deutsche Ofenplatten. - Leipzig : Bibliogr. Inst., 1936';
$mech->content_contains('"mediennr":"TEMP1446895"');
$mech->content_contains('"katkey":"979288"');
$mech->content_contains('"bvnr":"BV005390971"');
$mech->content_contains('"library_id":"3"');
done_testing();