use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Job;

ok( request('/job')->is_success, 'Request should succeed' );
done_testing();
