use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use English qw( -no_match_vars );
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
    make_path => [ File::Spec->catfile(qw( inArbeit ubr00003 ))  ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 )),
        },
        { glob => 'ubr00003_000?.xml',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 )),
        },
        { glob => 'ubr00003.pdf',
          dir  => File::Spec->catfile(qw( inArbeit ubr00003 )),
        }
    ]
});

my $job = Atacama::Worker::Job::Remedi->new(
    log_config_path => Path::Class::Dir->new($Bin,'..','config'),                                        
    order_id => 'ubr00003',                                        
    remedi_configfile => ( $OSNAME eq 'MSWin32'
                          ? "$Bin/../config/remedi_de-355_win32.conf"
                          : "$Bin/../config/remedi_de-355.conf" ),
    atacama_config_path => Path::Class::Dir->new($Bin,'..','config'),
    working_base => $working_base,
    source_format => 'PDF',
    source_pdf => Path::Class::File->new($working_dir, 'ubr00003.pdf'),
    does_digifooter => 1,
    
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

ok(-e File::Spec->catfile($working_dir, 'archive', 'ubr00003_0001.tif'), 'TIFF in archive');
ok(-e File::Spec->catfile($working_dir, 'ubr00003_0001.xml'), 'XML in working dir');
ok(-e File::Spec->catfile($working_dir, 'reference', 'ubr00003_0001.pdf'), 'PDF in reference');
ok(-e File::Spec->catfile($working_dir, 'thumbnail', 'ubr00003_0001.gif'), 'GIF in thumbnail');


done_testing();

