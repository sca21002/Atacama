use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Job::Error;

ok( request('/job/error')->is_success, 'Request should succeed' );
done_testing();
