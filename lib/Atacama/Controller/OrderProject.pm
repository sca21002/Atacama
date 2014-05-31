package Atacama::Controller::OrderProject;

# ABSTRACT: Controller OrderProject

use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

sub ordersprojects : Chained('/base') PathPart('orderproject') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{ordersprojects} = $c->model('AtacamaDB::OrderProject');
}

sub json : Chained('ordersprojects') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $ordersprojects = $c->stash->{ordersprojects};
    
    #$c->log->debug(Dumper($c->req->query_params));
    $json_data = $ordersprojects->get_new_result_as_href({
        project_id => $c->req->query_params->{project_id},                                            
    });
    #$c->log->debug(Dumper($json_data));    
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON'
    );
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__