use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
#use Path::Class;
use lib path($Bin)->child('lib')->stringify,
#        path($Bin)->parent->child('lib')->stringify,
    path($Bin)->parent(2)->child('Remedi','lib')->stringify,
    path($Bin)->parent(2)->child('Remedi','t','lib')->stringify
;

use Test::More;
use AtacamaTestSchema;
use Log::Log4perl::Appender::TestBuffer;

use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Job::Sourcefile' ) or exit;
    use_ok( 'Helper') or exit;
}

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );




Helper::prepare_input_files({
    input_dir =>  path($Bin)->parent(2)->child('Remedi','t','input_files')->stringify,
    rmdir_dirs => [ qw(archive reference thumbnail ingest) ],
    make_path => [ qw(archive reference thumbnail) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
        { glob => 'ubr00003_000?.pdf',
          dir  => 'reference',
        },
        { glob => 'ubr00003_000?.gif',
          dir  => 'thumbnail',
        },       
        'ubr00003.pdf',
    ],
});

my $args = {};
my %init_arg = (
    order_id => 'ubr00003',
    sourcedir =>  path($Bin)->parent(2)->child('Remedi','t','input_files')->stringify,
    skip_dirs => [ qr/thumbnail/, qr/save/],
);


my $job = Atacama::Worker::Job::Sourcefile->new( %init_arg );
$job->run;
#my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
#diag $app->buffer;
done_testing();
