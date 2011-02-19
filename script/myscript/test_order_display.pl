#!/usr/bin/perl -w
use strict;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Atacama::Schema;
use Carp;
use Data::Dumper;
use Template;


my $dsn_atacama = 'dbi:mysql:atacama';
my $user_atacama = 'db_user';
my $password_atacama =  'db_password';
my $param_atacama = {
    AutoCommit => 1,
    mysql_enable_utf8   => 1,
};

my $schema_atacama = Atacama::Schema->connect(
    $dsn_atacama,
    $user_atacama,
    $password_atacama,
    $param_atacama,
);

my $order = $schema_atacama->resultset('Order')->find('ubr02862');
carp "Gefunden: " . $order->modification_date;
my $var = $order->display;

print(Dumper($var));

my $tt = Template->new({
        INCLUDE_PATH => '../root/order',
        INTERPOLATE  => 1,
    }) || die "$Template::ERROR\n";

$tt->process('edit.tt', $var,'test.html')
        || die $tt->error(), "\n";