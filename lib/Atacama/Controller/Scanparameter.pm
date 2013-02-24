package Atacama::Controller::Scanparameter;
use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Scanparameter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Scanparameter in Scanparameter.');
}

sub scanparameters : Chained('/') PathPart('scanparameter') CaptureArgs(0) Does('NoSSL') {
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

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
