package Atacama::Controller::Job::Worker;
use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Job::Worker - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Job::Worker in Job::Worker.');
}


sub worker : Chained('/job/jobs') PathPart('worker') CaptureArgs(1) {
    my ($self, $c, $worker) = @_;
    
    my $class = 'Atacama::Worker::' . ucfirst $worker;
    Class::MOP::load_class($class);
}

sub add : Chained('worker') PathPart('add') Args(0) {
    my ($self, $c) = @_;
    
    $c->log->debug($c->log->debug(Dumper($c->req->params)));
    my $job = TheSchwartz::Job->new (
        funcname => 'Atacama::Worker::Remedi',
        arg => $c->req->params,
    );
    my $order_id = $c->req->params->{order_id};
    my $order = $c->model('AtacamaDB::Order')->find($order_id)
        or $c->detach('not_found');
    $c->model('TheSchwartzDB')->insert($job);
    $order->update({status_id => 24});
    $c->res->redirect(
        $c->uri_for_action('/order/edit', [$order_id] )
    );
}

sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Auftrag nicht gefunden!";
    $c->detach('list');
}


=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
