use Modern::Perl;
use Test::More;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, '..', 'lib'),
        File::Spec->catfile($Bin, '..', '..', 'lib');
use Test::MockObject;
use Test::MockModule;
use Data::Dumper;

BEGIN {
    use_ok( 'Atacama::Worker::Remedi' ) or exit;
    use_ok( 'Helper' ) or exit;
}

my $mets = Test::MockObject->new();
$mets->set_isa('Remedi::Mets');
$mets->mock('make_mets', sub { 'mets success' });

my $digifooter_module = new Test::MockModule('Remedi::DigiFooter');
$digifooter_module->mock('make_footer', sub { print 'digifooter success' });

my $mets_module = new Test::MockModule('Remedi::Mets');
    $mets_module->mock('new_with_config', sub { warn 'mets startet'; $mets });

my $csv_module = new Test::MockModule('Remedi::CSV');
        $csv_module->mock('make_csv', sub { print 'csv success' });
        
my $input_dir = File::Spec->catfile($Bin, '..',  'input_files');
Helper::prepare_input_files({
    input_dir =>  $input_dir,
    rmdir_dirs => [ qw( inArbeit ) ],
    make_path => [ qw( inArbeit/ubr00003 ) ],
    copy =>  [ 'ubr00003*.tif', 'ubr00003.pdf' ],
});

my $job = Test::MockObject->new();
$job->set_isa('TheSchwartz::Job');
$job->mock( 'arg',
    sub {
        return {
            order_id => 'ubr00003',
            atacama_config_path => "$Bin/../config",
            copy_files => 1,
            digifooter => 1,
            mets => 1,
            csv => 1,
            configfile => "$Bin/../config/remedi_de-355.yml",
            source_pdf_name => File::Spec->catfile($input_dir, 'ubr00003.pdf'),
            source_format => 'PDF',
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
    Titel => [
        [qw(order_id bvnr titel_avs)],
        ['ubr00003', 'BV111111111', 'Titel'],
    ],
    Scanfile => [
        [ qw( order_id filepath filename ) ],
        [ 'ubr00003', $input_dir, 'ubr00003_0001.tif'],
        [ 'ubr00003', $input_dir, 'ubr00003_0002.tif'],
        [ 'ubr00003', $input_dir, 'ubr00003_0003.tif'],
    ],
], 'Installed some custom fixtures via the Populate fixture class';

my $worker = Atacama::Worker::Remedi->new(
    atacama_schema => Order->result_source->schema
);
$worker->work($job);

isa_ok($worker->atacama_schema, 'Atacama::Schema');

is_fields 'order_id', $worker->order, ['ubr00003'], 'order_id';

is_fields 'status_id', $worker->order, ['26'], 'status update';

is($worker->remedi_config_file,
   Path::Class::File->new( "$Bin/../config", 'remedi_de-355.yml' ),
   'remedi_config_file'
);
my $scanfiles = $worker->scanfiles;
is( $scanfiles->[0]->filename, 'ubr00003_0001.tif', 'scanfiles' );
is( $scanfiles->[0]->filepath, $input_dir, 'filepath' );


sub log_file_name  { $worker->log_file_name(); }

done_testing();