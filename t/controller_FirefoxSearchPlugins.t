use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin,'lib'),
        File::Spec->catfile($FindBin::Bin,'..','lib');
use Helper;

use Catalyst::Test 'Atacama';
use Atacama::Controller::FirefoxSearchPlugins;

ok( request('/firefoxsearchplugins')->is_success, 'Request should succeed' );
done_testing();
