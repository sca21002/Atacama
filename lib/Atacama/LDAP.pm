package Atacama::LDAP;

# ABSTRACT: LDAP authentication

use parent Catalyst::Authentication::Store::LDAP;

use Atacama::LDAP::Backend;

sub new {
    my ( $class, $config, $app ) = @_;
    
    return Atacama::LDAP::Backend->new( $config, $app );
}

1; # Magic true value required at end of module

__END__