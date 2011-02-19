#!/usr/bin/perl -w
use strict;
use warnings;

use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin,'..','lib');
use Atacama::Schema;
use Carp;

my $attrs = {
    # add_drop_table => 1,
    no_comments => 1
            };



sub get_schema {
    my $dsn    = 'dbi:mysql:db_new';
    my $dbuser = 'db_user';
    my $dbpass = 'db_password';
    my $dbi_attributes = {mysql_enable_utf8 => '1'};
    return Atacama::Schema->connect($dsn, $dbuser, $dbpass, $dbi_attributes);
}


my $schema = get_schema();
$schema->deploy( $attrs );