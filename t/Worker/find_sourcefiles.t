use Modern::Perl;
use Test::More;
use Test::Deep;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Data::Dumper;
        
BEGIN {
    use_ok( 'Atacama::Worker::Job::Sourcefile' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'AtacamaTestSchema' ) or exit;
}
        
ok( my $schema = AtacamaTestSchema->init_schema(populate => 1),
    'created a test schema object' );
        
my $input_dir = File::Spec->catfile($Bin, '..',  'input_files');
my $working_dir  = File::Spec->catfile('inArbeit', 'ubr00003' );

Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ qw( ubr00003 inArbeit ) ],
    make_path => [ 'ubr00003', $working_dir ],
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

my $job = Atacama::Worker::Job::Sourcefile->new(
    log_config_path => Path::Class::Dir->new($Bin,'..','config'),
    atacama_config_path => Path::Class::Dir->new($Bin,'..','config'),
    working_dir => $working_dir,
    sourcedirs => [$input_dir],
    order_id => 'ubr00003',
);

$job->run();

cmp_deeply(
    $job->atacama_schema->resultset('Scanfile')->search(
        {},{result_class => 'DBIx::Class::ResultClass::HashRefInflator'}
    )->first,
    {
        filename =>  'ubr00003_0001.tif',
        filepath =>  re(qr/t.input_files.ubr00003/),
          volume =>  undef,
        order_id =>  'ubr00003',
          format =>  'TIFF',
       colortype =>  'color',
      resolution =>  75,
       height_px =>  691,
        width_px =>  430,
        filesize =>  800560,
             md5 =>  'cac550763dea8583132fd39c53c52868',
     icc_profile =>  'OS10000_A2_B5_mG',
           error =>  undef,
         deleted =>  undef,
    },
    'Scanfiles'
);

diag    Dumper( $job->atacama_schema->resultset('Pdffile')->search(
        {},{result_class => 'DBIx::Class::ResultClass::HashRefInflator'}
    )->all);

done_testing();

            


