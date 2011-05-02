use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::FirefoxSearchPlugins;

ok( request('/firefoxsearchplugins')->is_success, 'Request should succeed' );
done_testing();
