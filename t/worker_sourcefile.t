use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
#use Path::Class;
my $remedi_root;
BEGIN {
    die 'You must set REMEDI_ROOT' unless $ENV{REMEDI_ROOT};
    $remedi_root = path( $ENV{REMEDI_ROOT} );
}

use lib path($Bin)->child('lib')->stringify,
    path($Bin)->parent->child('lib')->stringify,
    $remedi_root->child('lib')->stringify,
    $remedi_root->child('t','lib')->stringify
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
    input_dir =>  $remedi_root->child('t','input_files')->stringify,
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
        'ubr00003.job',
    ],
});

my $args = {};
my %init_arg = (
    order_id => 'ubr00003',
    sourcedir =>  $remedi_root->child('t','input_files')->stringify,
    skip_dirs => [ qr/thumbnail/, qr/save/],
    single_page_re => qr/^ubr00003_\d{4}\.[A-Za-z]+$/,
    pdf_re => qr/^ubr00003\.pdf$/,
);


my $job = Atacama::Worker::Job::Sourcefile->new( %init_arg );
$job->run;
#my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
#diag $app->buffer;
done_testing()
