package Atacama::Model::TheSchwartzDB;

# ABSTRACT: Model for the job queue database

use strict;
use base 'Catalyst::Model';
use TheSchwartz;
use feature qw(say);
use DateTime;

sub COMPONENT {
    my ($class, $app, $args) = @_;
    $args = $class->merge_config_hashes($class->config, $args);
    my $client = TheSchwartz->new(
        databases => [$args->{connect_info}],
        verbose => sub {
            my $msg = shift;
            print STDERR "[INFO] $msg\n";
        },
    );
    my @dsns = keys %{ $client->{databases} };
    my $driver = $client->driver_for($dsns[0]);
    my $current_time = $client->get_server_time($driver);
    my $dt = DateTime->from_epoch(epoch => $current_time);
    say $dt->set_time_zone('Europe/Berlin')->strftime('%d.%m.%Y %T');
    return $client;
}

1; # Magic true value required at end of module

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

L<Catalyst::Model using schema L<TheSchwartz>
