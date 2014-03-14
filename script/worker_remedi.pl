#!/usr/bin/perl -w
use strict;
use warnings;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use FindBin;
use lib "$FindBin::Bin/../lib";
use Log::Log4perl qw(:easy);
use File::Spec;
use File::Path qw(remove_tree make_path);
use Config::ZOMG;
use DBI;
use Data::Dumper;
use TheSchwartz;
use Atacama::Worker::Remedi;
use Atacama::Worker::Sourcefile;

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . File::Spec->catfile(
                           $FindBin::Bin, '..', 'log', 'worker_remedi.log'
                       ),
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin, '..'),
);
my $config_hash = $config->load;

TRACE("reading configuration file" . join(', ', $config->found));

### Datenbankverbindung
my $dbic_connect_info = $config_hash->{'Model::TheSchwartzDB'}{connect_info};
LOGFATAL("No connect_info for the database found!")
    unless $dbic_connect_info;

my $dbh = DBI->connect(@$dbic_connect_info);
my $driver = Data::ObjectDriver::Driver::DBI->new( dbh => $dbh);
LOGFATAL("No database driver found!") unless $driver; 
my $client = TheSchwartz->new( databases => [{ driver => $driver }],
                               verbose => 1, );
my $current_time = $client->get_server_time($driver);
my $dt = DateTime->from_epoch(epoch => $current_time);
TRACE("Zeit: " . $dt->set_time_zone('Europe/Berlin')->strftime('%d.%m.%Y %T'));
remove_tree("/tmp/$EFFECTIVE_USER_ID");
make_path("/tmp/$EFFECTIVE_USER_ID");
$client->set_scoreboard("/tmp/$EFFECTIVE_USER_ID");
INFO("Scoreboard: " . $client->scoreboard); 
$client->can_do('Atacama::Worker::Remedi');
$client->can_do('Atacama::Worker::Sourcefile');
$client->work();
