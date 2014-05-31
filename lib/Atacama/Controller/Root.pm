package Atacama::Controller::Root;

# ABSTRACT: Root controller 

use Moose;
use Data::Dumper;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

sub base : Chained('/login/required') PathPart('') CaptureArgs(0) Does('NoSSL'){
    my ( $self, $c ) = @_;

    my $user;
    if ( $c->user_exists && ref($c->user) eq 'SCALAR' ){
        $user = $c->user;
    } else {
        $user = $c->user->username;
    }
    
    # my $roles =  $c->user->roles if $c->user_exists && $c->user->can('roles');
    # $c->log->debug( 'User: ' . $user->id );
    # $c->log->debug( 'Roles: ' . join(' ',@{$c->user->roles}));

    $c->stash(
        roles => [ 'user' ],
        user => $user,
    );
}

sub index : Chained('/base') PathPart('') {
    my ( $self, $c ) = @_;

    $c->stash(
        projects => [
            $c->model('AtacamaDB::Project')->search(
                undef,
                {order_by => 'name'}
            )->all
        ],      
        status => [ $c->model('AtacamaDB::Status')->search(
             undef, {
                join => [qw/ orders /],
                select => ['name', 'status_id', 
                      {count => 'orders.order_id', -as => 'order_count'} ],
                group_by => [qw/ me.status_id /]
        })->all ],
        orders => [ 
            map {
                $_->{status_name}
                ? $_
                :  { status_name => '(ohne)', order_count => $_->{order_count} } 
            } $c->model('AtacamaDB::Order')->get_status_order_count() 
        ]
    );
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
