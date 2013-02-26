package Atacama::Controller::Root;
use Moose;
use Data::Dumper;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Atacama::Controller::Root - Root Controller for Atacama

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub base : Chained('/login/required') PathPart('') CaptureArgs(0) Does('NoSSL'){
    my ( $self, $c ) = @_;
 
    my @roles = ('readonly');
    my $user;
    if ( $c->can('user') ) { 
        $user->{fullname}
            =  $c->user->can('urrzfullname') 
            ?  $c->user->urrzfullname
            : join(' ',
                $c->user->can('urrzgivenname') && $c->user->urrzgivenname,
                $c->user->can('urrzsurname')   && $c->user->urrzsurname
            );
        
        $user->{id} = $c->user->can('id') &&  $c->user->id;
        @roles =  $c->user->roles if  $c->user->can('roles');
    }
    $c->log->debug('User: ' . Dumper($user));

    $c->stash( 
	roles => [ @roles ],
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
                group_by => [qw/ status_id /]
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

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
