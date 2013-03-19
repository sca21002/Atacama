package Atacama;
use Moose;
use namespace::autoclean;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty

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
    -Debug
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
                    binddn              => 'anonymous',
                    bindpw              => 'dontcarehow',
                    class               => '+Atacama::LDAP',
                    ldap_server         => 'ldapauth1.uni-regensburg.de',
                    ldap_server_options => { 
				             timeout => 30,
					     raw => qr/(?i:^jpegPhoto|;binary)/,	
                                           },
                    start_tls           => 1,
                    start_tls_options   => { verify => 'none' },
                    entry_class         => 'Catalyst::Model::LDAP::Entry',
                    user_basedn         => 'o=uni-regensburg,C=de',
                    user_field          => 'cn',
                    user_filter         => '(&(objectClass=urrzUser)(cn=%s))',
                    user_scope          => 'sub', 
                    user_search_options => { deref => 'always' },
                    user_results_filter => sub { return shift->pop_entry },
                    user_class          => 'Atacama::LDAP::User',
                    user_model          => 'AtacamaDB::User',
                },
            },
        },
    },
    'Controller::Login' => {
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
    }
    
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
