use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Job::Worker;

ok( request('/job/worker')->is_success, 'Request should succeed' );
done_testing();
