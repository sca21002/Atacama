package Atacama;
use Moose;
use namespace::autoclean;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use Log::Log4perl::Catalyst;

use Catalyst::Runtime 5.80;
    with 'CatalystX::DebugFilter';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Unicode::Encoding
    Static::Simple
    +CatalystX::SimpleLogin
    Authentication
    Session
    Session::State::Cookie
    Session::Store::FastMmap
    StatusMessage
/;

extends 'Catalyst';

our $VERSION = '0.03';
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

__PACKAGE__->config( 'Plugin::ConfigLoader' => {
    driver => {
    'General' => { -UTF8 => 1 },
    }
    } );


__PACKAGE__->config(
    name => 'Atacama',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    
    'Plugin::ConfigLoader' => {
        driver => { 
            'General' => { -UTF8 => 1 },            # for utf8 in config file 
        }
    }, 
    'Plugin::Session' => {
        storage => "/tmp/session_$EFFECTIVE_USER_ID"                      
    },
    
    'authentication' => {
        default_realm => 'ldap',
        realms => {
            ldap => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'self_check',
                },
                store => {
                    class DBIx::Class
                    user_model AtacamaDB::User
                    role_relation roles
                    role_field  name      
                },
            },
        },
    },
    'Controller::Login' => {
        traits => ['-RenderAsTTTemplate'],  # remove trait to customize login tt                    
        login_form_args => {
            authenticate_username_field_name => 'id',
            authenticate_password_field_name => 'password',
        },
        action       => {
            login    => { Does => [qw( RequireSSL )] },
        },
    },
    'CatalystX::DebugFilter' => {
        Request => { params => [ 'password' ] },
    },
    'Model::AtacamaDB' => {
        traits =>  ( $ENV{ATACAMA_DEBUG} ? ['QueryLog::AdoptPlack'] : []),
    },
    
);

# Start the application
__PACKAGE__->setup();

__PACKAGE__->log(Log::Log4perl::Catalyst->new(
    __PACKAGE__->path_to('log4perl.conf')->stringify
));


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
