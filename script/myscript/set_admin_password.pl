#!/usr/bin/env perl
 
use strict;
use warnings;
use lib 'lib';
 
use Atacama;
use DateTime;
 
my $admin = Atacama->model('AtacamaDB::User')->search({ username => 'xxxxx' })->single;
 
$admin->update({ password => 'xxxxx', password_expires => DateTime->now });
