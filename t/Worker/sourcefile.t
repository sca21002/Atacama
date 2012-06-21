use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Test::MockObject;
        
BEGIN {
    use_ok( 'Atacama::Worker::Sourcefile' ) or exit;
    use_ok( 'Helper' ) or exit;
}


my $input_dir = File::Spec->catfile($Bin, '..', 'input_files');
Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ 'ubr00003' ],
    make_path => [ 'ubr00003' ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'ubr00003',
        },
        { glob => 'ubr00003.pdf',
          dir  => 'ubr00003',
        },        
    ],    
});

my $job = Test::MockObject->new();
$job->set_isa('TheSchwartz::Job');
$job->mock( 'arg',
    sub {
        return {
            order_id => 'ubr00003',
            atacama_config_path => "$Bin/../config",
        };
    }
);
$job->mock('completed', sub { 'job completed' } );

use Test::DBIx::Class { schema_class => 'Atacama::Schema' },
    'Order', 'Scanfile';    # only create the tables for the Order and Scanfile 
                            # Result classes

fixtures_ok [
    Order => [
        [qw(order_id)],
        ['ubr00003'],
    ],
], 'Installed some custom fixtures via the Populate fixture class';


my $worker = Atacama::Worker::Sourcefile->new(
    sourcedirs => [ $input_dir ],
    atacama_schema => Order->result_source->schema,
    log_dir => File::Spec->catfile($Bin, '..', 'log'),
);

my $test = [$input_dir];
is_deeply($worker->sourcedirs,$test,'sourcedirs');

$worker->work($job);

is($worker->order_id, 'ubr00003', 'order_id');
is( $worker->log_file_name,
    File::Spec->catfile($Bin, '..', 'log', 'sourcefile.log'),
    'log_file_name'
);

sub log_file_name  { $worker->log_file_name(); }

done_testing();