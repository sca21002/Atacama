package Atacama::Controller::Scanparameter;
use Moose;
use namespace::autoclean;

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

sub scanparameters : Chained('/') PathPart('scanparameter') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{scanparameters} = $c->model('AtacamaDB::Scanparameter');
}


sub scanparameter : Chained('scanparameters') PathPart('') CaptureArgs(1) {
    my ($self, $c, $scanparameter_id) = @_;

    my $scanparameter = $c->stash->{scanparameter} = $c->stash->{scanparameters}->find($scanparameter_id)
        || $c->detach('not_found');
}

sub json : Chained('scanparameter') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $scanparameter = $c->stash->{scanparameter};
    
    $json_data = {$scanparameter->get_inflated_columns};
    $json_data->{scanoptions} = $scanparameter->scanoptions;
     
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON'
    );
}


sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Scanparameter nicht gefunden!";
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
