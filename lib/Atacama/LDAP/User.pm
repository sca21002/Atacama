package Atacama::LDAP::User;

use parent Catalyst::Authentication::Store::LDAP::User;
use Data::Dumper::Concise;

BEGIN { __PACKAGE__->mk_accessors(qw(model)) }

sub new {
    my ( $class, $store, $user, $c ) = @_;
    
    return unless $user;
    $user->{attributes}{fullname}    
        =  exists $user->{attributes}{'urrzfullname'} && 
           $user->{attributes}{'urrzfullname'} 
        ? $user->{attributes}{'urrzfullname'}
        : join(' ', grep { defined $_ && $_ }   
                $user->{attributes}{'urrzgivenname'},
                $user->{attributes}{'urrzsurname'},   
          );
    my $model = $c->model($store->user_model);
    bless { store => $store, user => $user, model => $model }, $class;
}

sub roles {
    my ($self, $ldap) = @_;

    unless ( $self->{_roles}) {
        my $result = $self->model->find({username => $self->id});
        $self->{_roles} =  $result 
            ?  [ map { $_->name } $result->roles ] 
            :  ['readonly'];
    }
    return $self->{_roles};
}



1;
