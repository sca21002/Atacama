#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use  Log::Log4perl qw(:easy);
use File::Spec;
use Config::ZOMG;
use DBI;
use Data::Dumper;
use TheSchwartz::Moosified;
use Atacama::Worker::Remedi;

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

my $client = TheSchwartz::Moosified->new( databases => [$dbh],
                               verbose => 1, );
$client->can_do('Atacama::Worker::Remedi');
$client->work();
