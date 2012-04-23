package Atacama;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Unicode::Encoding
    Static::Simple
    +CatalystX::SimpleLogin
    Authentication
    Session
    Session::State::Cookie
    Session::Store::FastMmap    
/;

extends 'Catalyst';

our $VERSION = '0.02';
$VERSION = eval $VERSION;

has 'stage' => ( is => 'rw' ); 


# Configure the application.
#
# Note that settings in atacama.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Atacama',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    
    'Plugin::Session' => {
        storage => '/tmp/session_atacdev'
    },
    'Plugin::Authentication' => {
        default => {
            credential => {
                class => 'Password',
                password_field      => 'pass',
                password_type       => 'hashed',
                password_hash_type  => 'SHA-1',
            },
            store => {
                class => 'DBIx::Class',
                user_model => 'AtacamaWikiDB::Person',
            },
        },    
    },
    'Controller::Login' => {
            login_form_args => {
               authenticate_username_field_name => 'login',
               authenticate_password_field_name => 'pass',
            }
        },
    
);

# Start the application
__PACKAGE__->setup();


sub uri_for_static {
    my ( $self, $asset ) = @_;
    return ( $self->config->{static_path} || '/static/' ) . $asset;
}


=head1 NAME

Atacama - Catalyst based application

=head1 SYNOPSIS

    script/atacama_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Atacama::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
