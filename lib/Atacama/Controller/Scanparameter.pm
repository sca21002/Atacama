package Atacama::Controller::Scanparameter;

# ABSTRACT: Conroller for Scanparameter

use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

sub scanparameters : Chained('/base') PathPart('scanparameter') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{scanparameters} = $c->model('AtacamaDB::Scanparameter');
}

sub json : Chained('scanparameters') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $scanparameters = $c->stash->{scanparameters};
    
    $c->log->debug(Dumper($c->req->query_params));
    $json_data = $scanparameters->get_new_result_as_href({
        scanner_id => $c->req->query_params->{scanner_id},                                            
    });
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON'
    );
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
