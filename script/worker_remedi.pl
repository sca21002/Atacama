#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use  Log::Log4perl qw(:easy);
use File::Spec;
use File::Path qw(remove_tree);
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

### Konfiguration einlesen
#my $conf = Config::Any->load_stems({
#    stems => [ Path::Class::File->new( $FindBin::Bin, '..', 'atacama_local') ],
#    use_ext => 1,
#});
#my ($filename, $config) = %{shift @$conf};

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin, '..'),
);
my $config_hash = $config->load;

TRACE("Konfigurationsdatei(en) " . join(', ', $config->found) . " gelesen");

### Datenbankverbindung
my $dbic_connect_info = $config_hash->{'Model::AtacamaDB'}{connect_info};
LOGFATAL("Verbindungsparamter(connect_info) für die Datenbank nicht gefunden")
    unless $dbic_connect_info;

my $dbh = DBI->connect(@$dbic_connect_info);
my $driver = Data::ObjectDriver::Driver::DBI->new( dbh => $dbh);
LOGFATAL("Datenbank-Verbindung nicht gefunden!") unless $driver; 
my $client = TheSchwartz->new( databases => [{ driver => $driver }],
                               verbose => 1, );
my $current_time = $client->get_server_time($driver);
my $dt = DateTime->from_epoch(epoch => $current_time);
TRACE("Zeit: " . $dt->set_time_zone('Europe/Berlin')->strftime('%d.%m.%Y %T'));
remove_tree('/tmp/theschwartz');
$client->set_scoreboard('/tmp');
INFO("Scoreboard: " . $client->scoreboard); 
$client->can_do('Atacama::Worker::Remedi');
$client->can_do('Atacama::Worker::Sourcefile');
$client->work();
