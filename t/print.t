#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin, 'lib')->stringify,
        path($Bin)->parent->child('lib')->stringify; 
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
$mech->get_ok("/order/ubr00003/print");
my $temp = Path::Tiny->tempdir(CLEANUP => 0);
diag $temp;
path($temp, 'ubr00003.pdf')->spew_utf8($mech->content);
done_testing();
