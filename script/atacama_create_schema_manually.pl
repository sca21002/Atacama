#!/usr/bin/perl -w
use strict;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
make_schema_at(
    'Atacama::Schema',
    {  components    => [ qw/UTF8Columns/ ],
      debug => 1,
      dump_directory => '/home/atacama/test'  
    },
    [ 'dbi:mysql:atacama','atacama', <my password>, {AutoCommit => 1, mysql_enable_utf8 => 1} ],
);

