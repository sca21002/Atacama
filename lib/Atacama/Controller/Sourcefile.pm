package Atacama::Controller::Sourcefile;

# ABSTRACT: Conroller for searching and collecting files

use Moose;
use namespace::autoclean;
use Atacama::Form::Sourcefile;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

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
        if ( $c->req->params->{delete_scanfiles} ) {
            $c->log->debug('Loeschen der Scanfiles in der DB');    
            $order->scanfiles->delete_all() || $c->detach('error');
            $order->pdffiles->delete_all()  || $c->detach('error');
            $order->ocrfiles->delete_all()  || $c->detach('error');
        }
        my $job = TheSchwartz::Job->new (
            funcname => 'Atacama::Worker::Sourcefile',
            arg => {
                order_id => $order->order_id,
                scanfile_formats => (
                    ref $form->params->{scanfile_formats} eq 'ARRAY' 
                    ? $form->params->{scanfile_formats} 
                    : [ $form->params->{scanfile_formats} ]
                ),
                status_id => $order->status_id, 
            },
        );
        $c->model('TheSchwartzDB')->insert($job);
        $order->update({status_id => 25});
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

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
