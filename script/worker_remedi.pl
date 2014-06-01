#!/usr/bin/perl -w
use strict;
use warnings;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Log::Log4perl qw(:easy);
# use File::Spec;
use File::Path qw(remove_tree make_path);
use Config::ZOMG;
use DBI;
use Data::Dumper;
use TheSchwartz;
use Atacama::Worker::Remedi;
use Atacama::Worker::Sourcefile;

my $logpath = path(
    '/tmp', scalar getpwuid($EFFECTIVE_USER_ID), qw(atacama log worker.log)
);

$logpath->touchpath;

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">$logpath",
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => path($Bin)->parent,
);
my $config_hash = $config->load;

TRACE("reading configuration file" . join(', ', $config->found));

### Datenbankverbindung
my $dbic_connect_info = $config_hash->{'Model::TheSchwartzDB'}{connect_info};
LOGFATAL("No connect_info for the database found!") unless $dbic_connect_info;

my @dbic_connect_info;    
if (ref($dbic_connect_info) eq 'HASH') {
    @dbic_connect_info = @{$dbic_connect_info}{qw(dsn user pass)};    
} else {
    @dbic_connect_info = @$dbic_connect_info;
}

my $dbh = DBI->connect(@dbic_connect_info);
my $driver = Data::ObjectDriver::Driver::DBI->new( dbh => $dbh);
LOGFATAL("No database driver found!") unless $driver; 
my $client = TheSchwartz->new( 
    databases => [{ driver => $driver }],
    verbose => 1, 
);
my $current_time = $client->get_server_time($driver);
my $dt = DateTime->from_epoch(epoch => $current_time);
TRACE("Zeit: " . $dt->set_time_zone('Europe/Berlin')->strftime('%d.%m.%Y %T'));

my $scoreboard_dir = $config_hash->{'Atacama::Controller::Job'}{scoreboard_dir};
LOGFATAL("No scoreboard dir found!") unless $scoreboard_dir;
$scoreboard_dir = path($scoreboard_dir);
$scoreboard_dir->mkpath;

foreach my $file ( 
    $scoreboard_dir->child('theschwartz')->children( qr/scoreboard\.\d+$/ ) 
)  {
    $file->remove;
}

$client->set_scoreboard( $scoreboard_dir->stringify );
INFO("Scoreboard: " . $client->scoreboard); 
$client->can_do('Atacama::Worker::Remedi');
$client->can_do('Atacama::Worker::Sourcefile');
$client->work();
