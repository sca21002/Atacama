use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Atacama';
use Atacama::Controller::Scanner;

ok( request('/scanner')->is_success, 'Request should succeed' );
done_testing();
