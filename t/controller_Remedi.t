use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Remedi;

ok( request('/remedi')->is_success, 'Request should succeed' );
done_testing();
