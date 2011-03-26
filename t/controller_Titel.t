use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Atacama' }
BEGIN { use_ok 'Atacama::Controller::Titel' }

ok( request('/titel')->is_success, 'Request should succeed' );
done_testing();
