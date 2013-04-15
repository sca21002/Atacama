package Atacama::LDAP::Backend;

use parent Catalyst::Authentication::Store::LDAP::Backend;
use Carp;
use Storable qw(freeze thaw);
use Devel::Dwarn;

BEGIN { __PACKAGE__->mk_accessors(qw(user_model)); }

sub get_user {
    my $self = shift;
    
    carp "__PACKAGE__::get_user() called with params " . Dwarn @_;
    $self->next::method(@_);
}

sub from_session {
    my ( $self, $c, $frozenuser ) = @_;

    carp "__PACKAGE__::from_session() called with params " . Dwarn @_;
    local $Storable::Eval = 1;
    my $user = thaw $frozenuser;
    return $user;
}


1;
