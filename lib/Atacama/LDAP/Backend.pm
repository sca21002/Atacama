package Atacama::LDAP::Backend;

use parent Catalyst::Authentication::Store::LDAP::Backend;
use Carp (qw(carp cluck));
use Devel::Dwarn;

BEGIN { __PACKAGE__->mk_accessors(qw(user_model)); }

sub get_user {
    my $self = shift;
    cluck "Catalyst::Authentication::Store::LDAP::Backend::get_user() called with params " . Dwarn @_;
    $self->next::method(@_);
}

sub restore_user {
    $self = shift;
    carp "Catalyst::Authentication::Store::LDAP::Backend::restore_user() called with params " . Dwarn @_;
    $self->next::method(@_);   
}

1;
