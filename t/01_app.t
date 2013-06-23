#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify; 
use AtacamaTestSchema;
use SisisTestSchema;
use Test::More;
use Data::Dumper;
use HTTP::Cookies;

BEGIN {
    use_ok ('HTTP::Request::Common') or exit;
}

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

ok( my $sisis_schema = SisisTestSchema->init_schema(populate => 1),
    'created a sisis test schema object' );

$ENV{CATALYST_CONFIG} = file($Bin, qw(var atacama.conf));
 
use_ok( 'Catalyst::Test', 'Atacama' );
 
is( request('/')->code, 302, 'Get 302 from /' );            # redirect to login
my ($response, $c) = ctx_request(POST 'http://localhost/login',
        [username => 'admin', password => 'test']
);
ok($c->user_exists(), 'User logged in');
ok( $response->headers->header('set-cookie'), 'Cookie set when logging in.' );

my $cookie_jar = HTTP::Cookies->new();
$cookie_jar->extract_cookies($response);
my $request = HTTP::Request->new(GET => 'http://localhost/order/list');
$cookie_jar->add_cookie_header($request);
$response = request($request);

done_testing();

