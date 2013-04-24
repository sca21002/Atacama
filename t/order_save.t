use utf8;
use Modern::Perl;
use Test::More;
use Path::Class qw(dir file);
use FindBin qw($Bin);
use lib dir($Bin)->parent->subdir('lib')->stringify;
use Devel::Dwarn;

BEGIN {
    use_ok( 'Atacama::Helper' ) or exit;
}

my $schema = Atacama::Helper::get_schema(dir($Bin)->parent);

my $order = $schema->resultset('Order')->find('ubr3883');

diag $order->modification_date;

my $order_params = {
    'titel' => {
                 'autor_uw' => 'autor_1',
                 'bvnr' => 'BV005390971',
                 'library_id' => '',
                 'katkey' => '979288',
                 'signatur' => '999/Art.533',
                 'titel_uw' => 'titel_1',
                 'mediennr' => 'TEMP1446895',
                 'pages' => 'S 1 - 49'
               },
    'remark' => '',
    'copyright_id' => '',
    'ocr' => 0,
    'control' => '',
    'status_id' => '1',
    'documenttype_id' => '2'
};

$order->save($order_params);

is($order->order_id, 'ubr3883', 'Order_id');
is($order->titel->katkey, '979288', 'Katkey');

done_testing();
