use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Job::Remedi' );
    use_ok( 'Helper' );
    use_ok( 'AtacamaTestSchema' );
}

ok( my $schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a test schema object' );

my $input_dir    = File::Spec->catfile($Bin, '..',  'input_files');
my $working_base = File::Spec->catfile($input_dir, 'inArbeit');
my $working_dir  = File::Spec->catfile($working_base, 'ubr00003');

diag $working_dir;

Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ qw( inArbeit ubr00003 ) ],
    make_path => [ 'ubr00003', File::Spec->catfile(qw( inArbeit ubr00003 ))],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'ubr00003',
        },
        { glob => 'ubr00003_000?.xml',
          dir  => 'ubr00003',
        },
        { glob => 'ubr00003.pdf',
          dir  => 'ubr00003',
        }    
    ]
});

my $job = Atacama::Worker::Job::Remedi->new(
    log_config_path => Path::Class::Dir->new($Bin,'..','config'),                                        
    order_id => 'ubr00003',                                        
    remedi_configfile => "$Bin/../config/remedi_de-355.conf",
    atacama_config_path => Path::Class::Dir->new($Bin,'..','config'),
    working_base => $working_base,
    source_format => 'PDF',
    source_pdf => Path::Class::File->new($input_dir,'ubr00003','ubr00003.pdf'),
    does_copy_files => 1,
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

$job->atacama_schema->resultset('Scanfile')->populate(
    [
        {
           'height_px' => '691',
           'volume' => undef,
           'icc_profile' => 'OS10000_A2_B5_mG',
           'order_id' => 'ubr00003',
           'colortype' => 'color',
           'deleted' => undef,
           'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
           'filesize' => '800560',
           'format' => 'TIFF',
           'filename' => 'ubr00003_0001.tif',
           'resolution' => '75',
           'error' => undef,
           'width_px' => '430',
           'md5' => 'cac550763dea8583132fd39c53c52868'
        },
        {
           'height_px' => '692',
           'volume' => undef,
           'icc_profile' => 'OS10000_A2_B5_mG',
           'order_id' => 'ubr00003',
           'colortype' => 'color',
           'deleted' => undef,
           'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
           'filesize' => '763748',
           'format' => 'TIFF',
           'filename' => 'ubr00003_0002.tif',
           'resolution' => '75',
           'error' => undef,
           'width_px' => '433',
           'md5' => '6a67eb88d2d170cb68a00a4742bdad85'
        },
        {
           'height_px' => '691',
           'volume' => undef,
           'icc_profile' => 'OS10000_A2_B5_mG',
           'order_id' => 'ubr00003',
           'colortype' => 'color',
           'deleted' => undef,
           'filepath' => 'C:\\Users\\sca21002\\Documents\\Perl\\Atacama\\t\\input_files\\ubr00003',
           'filesize' => '973892',
           'format' => 'TIFF',
           'filename' => 'ubr00003_0003.tif',
           'resolution' => '75',
           'error' => undef,
           'width_px' => '430',
           'md5' => '6cffb6e7c200f09f21f971b6d9157bc7'
        },
    ]
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

$job->run;

ok(-e File::Spec->catfile($working_dir, 'ubr00003_0001.tif'), 'TIFF kopiert');
ok(-e File::Spec->catfile($working_dir, 'ubr00003_0001.xml'), 'XML kopiert');
ok(-e File::Spec->catfile($working_dir, 'ubr00003.pdf'), 'PDF kopiert');

done_testing();

