package Atacama::Helper;

# ABSTRACT: Helper functions for Atacama

use Carp;
use Config::ZOMG;
use Path::Class qw(dir file);
use Atacama::Schema;


sub get_schema {
    my $config_dir = shift;
    
    croak "Aufruf: get_schema( [configdir] )" unless $config_dir;
    croak "Kein Konfigurationsverzeichnis: $config_dir" unless -d $config_dir;
    my $config_hash = Config::ZOMG->open(
        name => 'atacama',
        path => $config_dir,
    ) or croak "Keine Konfigurationsdatei gefunden in $config_dir";
    my @dbic_connect_info
        = @{ $config_hash->{'Model::AtacamaDB'}{connect_info} };
    croak "Keine Datenbank-Verbindungsinformationen" unless  @dbic_connect_info;
    my $schema = Atacama::Schema->connect(@dbic_connect_info);
    $schema->storage->ensure_connected;
    return $schema;
}

1;
