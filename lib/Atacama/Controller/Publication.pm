package Atacama::Controller::Publication;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Publication - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub publications : Chained('/base') PathPart('publication') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{publications} = $c->model('AtacamaDB::Publication');
}

sub json : Chained('publications') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $publications = $c->stash->{publications};
    
    $c->log->debug(Dumper($c->req->query_params));
    $json_data = $publications->get_new_result_as_href({
        platform_id => $c->req->query_params->{platform_id},                                            
    });
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON',
    );
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
