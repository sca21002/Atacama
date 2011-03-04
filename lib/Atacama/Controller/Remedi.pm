package Atacama::Controller::Remedi;
use Moose;
use namespace::autoclean;
use Atacama::Form::Remedi;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Remedi - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Remedi in Remedi.');
}

sub remedi : Chained('/order/order') PathPart('remedi') Args(0) {
    my ( $self, $c ) = @_;
    
    my $order = $c->stash->{order};
    my $remedi_configdir = $c->config->{'Controller::Remedi'}{remedi_configdir};
    my $form = Atacama::Form::Remedi->new(
        order => $order,                                  
        remedi_configdir => $remedi_configdir,
    );
    $form->process( params => $c->req->params );
    if( $form->validated ) {
        # perform validated form actions
        $c->res->redirect($c->uri_for_action('/order/edit', $c->req->captures));
    }
    else {
        # perform non-validated actions
    }


    $c->stash(
        order    => $order,
        form     => $form,
        template => 'remedi/remedi.tt',
    );     
}


=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
