use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use Path::Class;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify,
        path($Bin)->parent(2)->child('Remedi','lib')->stringify,
        path($Bin)->parent(2)->child('Remedi','t','lib')->stringify;
        
use Test::More;
use AtacamaTestSchema;
use Log::Log4perl::Appender::TestBuffer;

use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Job::Remedi' ) or exit;
    use_ok( 'Helper' ) or exit;
}

ok( my $atacama_schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a atacama test schema object' );

$atacama_schema->resultset('Order')->create(
    {
        order_id => 'ubr00003',
        titel => {
            bvnr => 'BV111111111',
            titel_avs => 'Mein Titel',
        }
    }
);

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


my %init_arg = (
    remedi_configfile => path($Bin)->parent(2)->child('Remedi','t','config','remedi_de-355.conf')->stringify,
    log_config_file => path($Bin)->parent(2)->child('Remedi','t','config', 'log4perl.conf')->stringify,
    atacama_config_path => path($Bin)->child('var')->stringify,
    order_id => 'ubr00003',
    does_csv => 1,
    does_mets => 1,
    image_path => '.',
    source_pdf_file  => path($Bin)->parent(2)->child('Remedi','t','input_files', 'ubr00003.pdf')->stringify,
);
my $job = Atacama::Worker::Job::Remedi->new(%init_arg);
$job->run;
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
diag $app->buffer;
done_testing();