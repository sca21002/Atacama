#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify;

use Test::More;
use Test::WWW::Mechanize::Catalyst;
use SisisTestSchema;
use AtacamaTestSchema;
use Data::Dumper;

#$ENV{ATACAMA_DEBUG} = 1;

ok( my $sisis_schema = SisisTestSchema->init_schema(populate => 1),
    'created a sisis test schema object' );

my $data;
$data = {
    katkey => 979288,
    mcopyno => 979288,
    seqnr => 1,        
};
$sisis_schema->resultset('TitelBuchKey')->create($data);
$data = {
        d01gsi => 'TEMP1446895',
        d01ex  => ' ',
        d01zweig => 3,
        d01ort => '999/Art.533',
        d01mcopyno => 979288,
        d01titlecatkey => 979288,
        d01usedcatkey => 979288,                
};
$sisis_schema->resultset('D01buch')->create($data);        
$data = {
    katkey => 979288,
    autor_avs => 'Schröder, Albert',
    titel_avs => 'Deutsche Ofenplatten',
    verlagsort => 'Leipzig',
    verlag => 'Bibliogr. Inst.',
    erschjahr => '1936',         
};
$sisis_schema->resultset('TitelDupdaten')->create($data);
$data = {
    katkey => 979288,
    verbundid => 'BV005390971',
};
$sisis_schema->resultset('TitelVerbund')->create($data);

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