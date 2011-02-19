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

use constant cm_pro_inch => 2.54;


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

my $scanfile_rs = $schema_atacama->resultset('Scanfile')->search(
    { order_id => 'ubr02862' },
    {
        #'+select' => [
        #    \'height_px * width_px AS area_px',
        #    \'height_px * width_px / resolution * 2.54 AS area_cm',
        #],
        #'+as' => [qw/
        #  area_px
        #  area_cm
        #/],
        order_by => { -desc => \'height_px * width_px' },
    }
);


carp "Gefunden: " . $scanfile_rs->count;

while (my $scanfile = $scanfile_rs->next) {
    print $scanfile->filename,
    # ": ", $scanfile->get_column('area_px'), " : " ,
    # $scanfile->get_column('area_cm'),
    "\n";
}
