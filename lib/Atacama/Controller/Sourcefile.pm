package Atacama::Controller::Sourcefile;
use Moose;
use namespace::autoclean;
use Atacama::Form::Sourcefile;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Sourcefile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Sourcefile in Sourcefile.');
}

sub sourcefile : Chained('/order/order') PathPart('sourcefile') Args(0) {
    my ( $self, $c ) = @_;
    
    my $order = $c->stash->{order};
    my $form = Atacama::Form::Sourcefile->new(
        order => $order,                                  
    );
    $form->process( params => $c->req->params );
    if( $form->validated ) {
        # perform validated form actions
        $c->log->debug($c->log->debug(Dumper($c->req->params)));
        my $job = TheSchwartz::Job->new (
            funcname => 'Atacama::Worker::Sourcefile',
            # arg => $c->req->params,
            arg => { order_id => $order->order_id },
        );
        $c->model('TheSchwartzDB')->insert($job);    
        $c->res->redirect(
            $c->uri_for_action('/order/edit', [$order->order_id] )
        );        

    }
    else {
        # perform non-validated actions
    }


    $c->stash(
        order    => $order,
        form     => $form,
        template => 'sourcefile/sourcefile.tt',
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
