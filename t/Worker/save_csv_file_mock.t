use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Test::MockObject;
use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Remedi' ) or exit;
    use_ok( 'Helper' ) or exit;
}

my $input_dir = File::Spec->catfile($FindBin::Bin, '..', 'input_files');
Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ qw(inArbeit data) ],
    make_path => [ qw(inArbeit/ubr00003 data) ],
});

my $job = Test::MockObject->new();

$job->set_isa('TheSchwartz::Job');
$job->mock( 'arg',
    sub {
        return {
            order_id => 'ubr00003',
            atacama_config_path => "$Bin/../config",
            copy_files => 1,
        };
    }
);

Path::Class::File->new(
    $input_dir, 'inArbeit', 'ubr00003', 'ubr00003.csv'
)->touch;

my $worker = Atacama::Worker::Remedi->new();
$worker->work($job);

ok($worker->does_copy_files, 'does copy files');
ok(-e Path::Class::File->new(
        $input_dir, 'inArbeit', 'csv_save', 'ubr00003.csv'
      ),
    'csv file saved'
);   
ok( ( grep {/ubr00003_[-0-9]*\.csv$/}
         Path::Class::Dir->new($input_dir, 'inArbeit', 'ubr00003')->children
    ),
    'restored csv file'
);

sub log_file_name  { $worker->log_file_name(); }

done_testing();