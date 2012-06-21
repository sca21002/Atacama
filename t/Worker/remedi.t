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
    make_path => [ qw(inArbeit data) ],
});

my $job = Test::MockObject->new();

$job->set_isa('TheSchwartz::Job');
$job->mock( 'arg',
    sub {
        return {
            order_id => 'ubr12224',
            atacama_config_path => "$Bin/../config",
            copy_files => 1,
        };
    }
);

my $worker = Atacama::Worker::Remedi->new();
$worker->work($job);

is( $worker->log_file_name,
    Path::Class::File->new($worker->work_dir, 'remedi.log'),
    'log_file_name'
);

is( $worker->log_config_file,
    Path::Class::File->new("$Bin/../config", 'log4perl_remedi.conf')->absolute,
    'log_configfile');

is( $worker->csv_file,
    Path::Class::File->new("$Bin/../input_files/inArbeit/ubr12224/ubr12224.csv"),
    'csv-file'
);
is($worker->csv_save_dir, 't\input_files\inArbeit\csv_save', 'csv_save_dir');

sub log_file_name  { $worker->log_file_name(); }

done_testing();
