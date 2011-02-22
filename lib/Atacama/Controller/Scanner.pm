package Atacama::Controller::Scanner;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Scanner - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Scanner in Scanner.');
}

sub scanners : Chained('/') PathPart('scanner') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{scanners} = $c->model('AtacamaDB::Scanner');
}


sub scanner : Chained('scanners') PathPart('') CaptureArgs(1) {
    my ($self, $c, $scanner_id) = @_;

    my $scanparameter = $c->stash->{scanparameter} = $c->stash->{scanparameters}->find($scanparameter_id)
        || $c->detach('not_found');
}

sub json : Chained('scanner') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $scanner = $c->stash->{scanner};
    
    $json_data = {$scanner->get_inflated_columns};
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
