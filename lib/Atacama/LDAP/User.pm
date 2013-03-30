package Atacama::LDAP::User;

use parent Catalyst::Authentication::Store::LDAP::User;
use Data::Dumper;


BEGIN { __PACKAGE__->mk_accessors(qw(model)) }

sub new {
    my ( $class, $store, $user, $c ) = @_;
    
    return unless $user;
            
    my $fullname 
        =  $user->can('urrzfullname') 
        ?  $user->urrzfullname
        : join(' ',
            grep { defined $_ && $_ }   
                $user->can('urrzgivenname') && $user->urrzgivenname,
                $user->can('urrzsurname')   && $user->urrzsurname
    );
    $user->fullname($fullname);
    my $model = $c->model($store->user_model);
    bless { store => $store, user => $user, model => $model }, $class;
}

sub roles {
    my ($self, $ldap) = @_;

    unless ( $self->{_roles}) {
        my $result = $self->model->find({username => $self->id});
        $self->{_roles} =  $result 
            ?  map { $_->name } $result->roles 
            : ();
    }
    return @{$self->{_roles}};
}



1;
