
use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Test::MockObject;
use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Base' ) or exit;
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
         };
    }
);

my $worker = Atacama::Worker::Base->new();
$worker->work($job);

is($worker->order_id, 'ubr12224', 'order_id');
is(
   $worker->atacama_config_path,
   Path::Class::File->new("$Bin/../config")->absolute,
   'atacama_config_path'
);

is(Path::Class::Dir->new($worker->work_base),
   Path::Class::File->new("$Bin/../input_files/inArbeit"),
   'work_base',
);

is( Path::Class::Dir->new($worker->work_dir),
    Path::Class::File->new("$Bin/../input_files/inArbeit/ubr12224"),
    'work_dir'
);

is( $worker->log_file_name,
    Path::Class::File->new($worker->work_dir, 'worker.log'),
    'log_file_name'
);

is( $worker->log_config_file,
    Path::Class::File->new("$Bin/../config", 'log4perl.conf')->absolute,
    'log_configfile');

done_testing();
