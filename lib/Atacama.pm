package Atacama;

# ABSTRACT: Atacama - a Catalyst based web application for digitisation orders 

use Moose;
use MooseX::AttributeShortcuts;
use namespace::autoclean;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use Log::Log4perl::Catalyst;
use CPAN::Changes;
use DateTime::Format::W3CDTF;

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
    Static::Simple
    +CatalystX::SimpleLogin
    Authentication
    Session
    Session::State::Cookie
    Session::Store::FastMmap
    StatusMessage
/;

extends 'Catalyst';

has 'last_modified' => ( is => 'lazy', isa => 'Str' );

has 'stage' => ( is => 'rw' ); 

sub _build_last_modified {

    my $changes = CPAN::Changes->load( 'Changes' );
    my $date = ($changes->releases)[-1]->date;
    my $dt = DateTime::Format::W3CDTF->new()->parse_datetime( $date );
    return $dt->strftime('%d.%m.%Y %H:%M')
}

sub log_file_name {
    my $logfile =  __PACKAGE__->path_to('log', 'atacama.log');
    $logfile->dir->mkpath();
    $logfile->stringify;    
}


# Configure the application.
#
# Note that settings in atacama.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( 'Plugin::ConfigLoader' => {
        driver => { 'General' => { -UTF8 => 1 } }
    } );


__PACKAGE__->config(
    name => 'Atacama',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    # Plugin Unicode::Encode is auto-applied, config this plugin for UTF-8
    encoding => 'UTF-8',
    
    'Plugin::ConfigLoader' => {
        driver => { 
            'General' => { -UTF8 => 1 },            # for utf8 in config file 
        }
    }, 
    'Plugin::Session' => {
        storage => "/tmp/session_$EFFECTIVE_USER_ID"                      
    },
    
    'authentication' => {
        default_realm => 'users',
        realms => {
            users => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'self_check',
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'AtacamaDB::User',
                    role_relation => 'roles',
                    role_field  => 'name',      
                },
            },
        },
    },
    'Controller::Login' => {
        traits => ['-RenderAsTTTemplate'],  # remove trait to customize login tt                    
        login_form_args => {
            authenticate_username_field_name => 'username',
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

1; # Magic true value required at end of module

__END__

=head1 SYNOPSIS

    script/atacama_server.pl

=head1 DESCRIPTION

Atacama is a web application to manage the whole digitisation process from
creating a digitisation order to publishing the digital object on the web.
Digitisation orders are stored in a database.
The actual position of an order in the workflow process is described by a set of
status values.
Orders can be assigned to one or more projects to organize the digitisation
jobs.

=head1 SEE ALSO

L<Atacama::Controller::Root>, L<Catalyst>

