use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Job::Queue;

ok( request('/job/queue')->is_success, 'Request should succeed' );
done_testing();
