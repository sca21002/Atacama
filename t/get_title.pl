#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify;

use Test::More;
use Test::WWW::Mechanize::Catalyst 'Atacama';
use Data::Dumper;
use AtacamaTestSchema;



ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

use Atacama;
my $config = Atacama->config;

$config->{'Model::AtacamaDB'} = {
    connect_info => $atacama_schema->storage->connect_info,
};

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok("/login");

$mech->submit_form_ok( {
        form_id => 'login_form',
        fields  => {
            username => 'admin',
            password => 'test',
        },
    }, 'now we just need the question'
);

$mech->get_ok("/titel/json?signatur=999/Art.533");
my $str = 'Deutsche Ofenplatten. - Leipzig : Bibliogr. Inst., 1936';
$mech->content_contains($str);
$str = '"mediennr":"TEMP1446895"';
$mech->content_contains($str);
$str = '"katkey":"979288"';
$mech->content_contains($str);
$str = '"bvnr":"BV005390971"';
$mech->content_contains($str);
$str = '"library_id":"3"';
$mech->content_contains($str);
done_testing();