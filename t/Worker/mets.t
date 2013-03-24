use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Job::Remedi' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'AtacamaTestSchema' ) or exit;
}

ok( my $schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a test schema object' );

my $input_dir    = File::Spec->catfile($Bin, '..',  'input_files');
my $working_base = File::Spec->catfile($input_dir, 'inArbeit');
my $working_dir  = File::Spec->catfile($working_base, 'ubr00003');


Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ qw( inArbeit ) ],
    make_path => [
        File::Spec->catfile(qw( inArbeit ubr00003 archive)),
        File::Spec->catfile(qw( inArbeit ubr00003 reference)),
        File::Spec->catfile(qw( inArbeit ubr00003 thumbnail)),
    ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 archive)),
        },
        { glob => 'ubr00003_000?.xml',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 )),
        },
        { glob => 'ubr00003_000?.pdf',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 reference)),
        },
        { glob => 'ubr00003_000?.gif',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 thumbnail)),
        },
    ],
});

my $job = Atacama::Worker::Job::Remedi->new(
    log_config_path => Path::Class::Dir->new($Bin,'..','config'),                                        
    order_id => 'ubr00003',                                        
    remedi_configfile => "$Bin/../config/remedi_de-355_win32.conf",
    atacama_config_path => Path::Class::Dir->new($Bin,'..','config'),
        does_mets => 1,
);

$job->atacama_schema->resultset('Ocrfile')->populate(
    [
        {
            'volume' => undef,
            'order_id' => 'ubr00003',
            'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
            'filesize' => '57393',
            'filename' => 'ubr00003_0001.xml',
            'format' => 'XML',
            'error' => undef,
            'md5' => '05dcf9052e5ea56f7553ea17b320b292'
        },
        {
            'volume' => undef,
            'order_id' => 'ubr00003',
            'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
            'filesize' => '2300',
            'filename' => 'ubr00003_0002.xml',
            'format' => 'XML',
            'error' => undef,
            'md5' => '716afea3f0d2693f0f953ec59d0d6c5a'
        },
        {
            'volume' => undef,
            'order_id' => 'ubr00003',
            'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
            'filesize' => '413553',
            'filename' => 'ubr00003_0003.xml',
            'format' => 'XML',
            'error' => undef,
            'md5' => 'cb2ba0e3dfbbc1e8abf91e902bf11bd2'
        },
    ]
);


$job->atacama_schema->resultset('Status')->populate(
    [
        {
            name => 'Remedi: in Bearbeitung',
            status_id => '22',
        },
        {
            name => 'Remedi: fertig',
            status_id => '26',
        },
    ],
);

$job->run;

ok(-e File::Spec->catfile($working_dir, 'ingest', 'ubr00003_0001.tif'), 'TIFF in ingest');
ok(-e File::Spec->catfile($working_dir, 'ingest', 'ubr00003_0001.xml'), 'XML in ingest');
ok(-e File::Spec->catfile($working_dir, 'ingest', 'ubr00003_0001.pdf'), 'PDF in ingest');
ok(-e File::Spec->catfile($working_dir, 'ubr00003.xml'), 'METS file in working_dir');

done_testing();

