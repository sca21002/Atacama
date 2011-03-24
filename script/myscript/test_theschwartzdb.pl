#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use Data::Dumper;
use Carp;
use DBI;
use Data::ObjectDriver::Driver::DBI;
use TheSchwartz;
use DateTime;


binmode(STDOUT, ":utf8");

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my $connect = $config_hash->{'Model::TheSchwartzDB'}{connect_info};  

while ( my($key,$val) = each(%$connect)) { 
    say "$key: $val";
}


my $client =  TheSchwartz->new(
        databases => [$connect],
        verbose => sub {
            my $msg = shift;
            print STDERR "[INFO] $msg\n";
        },
);

my @dsns = keys %{ $client->{databases} };
my $driver = $client->driver_for($dsns[0]);
my $current_time = $client->get_server_time($driver);



#my $dbh = DBI->connect( $connect->{dsn}, $connect->{user} . 'hallo' , $connect->{pass}, {
#                RaiseError => 1,
#                PrintError => 0,
#                AutoCommit => 1,
#} ) or die $DBI::errstr;
#
#my $driver = Data::ObjectDriver::Driver::DBI->new( dbh => $dbh);
#
#my $client =  TheSchwartz->new(databases => [{ driver => $driver }]);
#
#my $server_time = $client->get_server_time( $driver );
my $dt = DateTime->from_epoch(epoch => $current_time);

say $dt->strftime("%r");

say Dumper($client);