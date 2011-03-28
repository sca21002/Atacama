use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Sourcefile;

ok( request('/sourcefile')->is_success, 'Request should succeed' );
done_testing();
