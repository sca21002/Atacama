#!/usr/bin/perl -w
use strict;

use strict;
use warnings;
use File::Spec;
use lib File::Spec->catfile(File::Spec->rootdir(), qw( home atacama AtacamaWiki lib ));
use AtacamaWiki::Schema;
use Carp;
use Data::Dumper;


my $dsn_atacamawiki = 'dbi:mysql:atacamawiki';
my $user_atacamawiki = 'atacamawiki_user';
my $password_atacamawiki =  'atacamawiki_password';
my $param_atacamawiki = {
    AutoCommit => 1,
    mysql_enable_utf8   => 1,
};

my $schema_atacamawiki = AtacamaWiki::Schema->connect(
    $dsn_atacamawiki,
    $user_atacamawiki,
    $password_atacamawiki,
    $param_atacamawiki,
);

my $person = $schema_atacamawiki->resultset('Person')->find(1);
print $person->name, "\n";
# carp "Gefunden: " . $order->modification_date;


