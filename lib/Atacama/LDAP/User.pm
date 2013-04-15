package Atacama::LDAP::User;

use parent Catalyst::Authentication::Store::LDAP::User;


sub new {
    my ( $class, $store, $user, @args ) = @_;
    
    return unless $user;
    $user->{attributes}{fullname}    
        =  exists $user->{attributes}{'urrzfullname'} && 
           $user->{attributes}{'urrzfullname'} 
        ? $user->{attributes}{'urrzfullname'}
        : join(' ', grep { defined $_ && $_ }   
                $user->{attributes}{'urrzgivenname'},
                $user->{attributes}{'urrzsurname'},   
          );

    Catalyst::Authentication::Store::LDAP::User->new(
        $class, $store, $user, @args
    );
}

sub roles {
    my ($self, $ldap) = @_;

    unless ( $self->{_roles}) {
        my $model = $c->model($store->user_model);
        my $result = $model->find({username => $self->id});
        $self->{_roles} =  $result 
            ?  [ map { $_->name } $result->roles ] 
            :  ['readonly'];
    }
    return $self->{_roles};
}

sub for_session {
    carp 'In ' . __PACKAGE__ . ': method for_session'; 
    my $self = shift;
    local $Storable::Deparse = 1;
    return freeze $self;
}




1;
