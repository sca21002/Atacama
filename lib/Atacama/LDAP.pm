package Atacama::LDAP;

use parent Catalyst::Authentication::Store::LDAP;

use Atacama::LDAP::Backend;

sub new {
    my ( $class, $config, $app ) = @_;
    
    return Atacama::LDAP::Backend->new( $config, $app );
}



1;
