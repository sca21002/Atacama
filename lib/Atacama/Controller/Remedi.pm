package Atacama::Controller::Remedi;

# ABSTRACT: Controller Remedi

use Moose;
use namespace::autoclean;
use Atacama::Form::Remedi;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

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
        
        # funcname => 'Atacama::Worker::Remedi',
        my %query_values = (
            order_id => $order->order_id,
        );
        foreach my $key ( qw(
            remedi_configfile
            source_format
            source_pdf_file
            jpeg2000_list
            does_copy_files
            does_digifooter
            does_mets
            does_csv
            is_thesis_workflow
            log_level
        )) {
            $query_values{$key} = $form->params->{$key}
                if $form->params->{$key};
        }
        $c->log->debug(\%query_values);
        $c->res->redirect(
            $c->uri_for_action( '/job/worker/add', ['remedi'], \%query_values )
        );
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

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
