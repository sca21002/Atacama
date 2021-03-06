package Atacama::Controller::Job::Worker;

# ABSTRACT: Controller for a Worker of the job queue

use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

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

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
