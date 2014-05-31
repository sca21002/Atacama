package Atacama::Helper;

# ABSTRACT: Helper functions for Atacama

use Carp;
use Config::ZOMG;
use Module::Runtime qw(use_module);
use Data::Dumper;
use Modern::Perl;

sub get_schema {
    my ($config_dir, $model, $schemaclass, $name) = @_;
    $model       ||= 'Model::AtacamaDB';
    $schemaclass ||= 'Atacama::Schema';
    $name        ||= 'atacama';
    
    croak "Aufruf: get_schema( [configdir] )" unless $config_dir;
    croak "Kein Konfigurationsverzeichnis: $config_dir" unless -d $config_dir;
    my $config_hash = Config::ZOMG->open(
        name => $name,
        path => $config_dir,
    ) or croak "Keine Konfigurationsdatei gefunden in $config_dir";
    my $connect_info =  $config_hash->{$model}{connect_info} or
        croak "Keine Datenbankverbindungsparameter"; 
    my @dbic_connect_info;
    if (ref $connect_info eq 'HASH') {
        @dbic_connect_info = delete @$connect_info{ qw(dsn user password) };
        push @dbic_connect_info, $connect_info;
    } elsif (ref $connect_info eq 'ARRAY') {
         @dbic_connect_info = @$connect_info;
    } else { croak("Falscher Typ fuer connect_info: " . ref  $connect_info); }    
    croak "Keine Datenbank-Verbindungsinformationen" unless  @dbic_connect_info;
    say Dumper(\@dbic_connect_info);
    my $schema = use_module($schemaclass)->connect(@dbic_connect_info);
    $schema->storage->ensure_connected;
    return $schema;
}

1; # Magic true value required at end of module

__END__