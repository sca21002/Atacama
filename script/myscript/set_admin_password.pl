#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Path::Class qw(dir file);
use FindBin qw($Bin);
use lib dir($Bin)->parent->parent->subdir('lib')->stringify; 
 
use Atacama;
use DateTime;
 
my $admin = Atacama
            ->model('AtacamaDB::User')->search({ username => 'xxxxx' })->single;
 
$admin->update({ password => 'xxxxx', password_expires => DateTime->now });
