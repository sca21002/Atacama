package Atacama::LDAP::User;

use parent Catalyst::Authentication::Store::LDAP::User;

BEGIN { __PACKAGE__->mk_accessors(qw(model)) }

sub new {
    my ( $class, $store, $user, $c ) = @_;

    return unless $user;
    my $model = $c->model($store->user_model);
    bless { store => $store, user => $user, model => $model }, $class;
}

sub roles {
    my ($self, $ldap) = @_;

    $self->{_roles} ||= [
        map { $_->name } $self->model->find({username => $self->id})->roles
    ];
    return @{$self->{_roles}};
}



1;
