use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Atacama' }
BEGIN { use_ok 'Atacama::Controller::Publication' }

ok( request('/publication')->is_success, 'Request should succeed' );
done_testing();
