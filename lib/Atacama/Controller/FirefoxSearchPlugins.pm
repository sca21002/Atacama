package Atacama::Controller::FirefoxSearchPlugins;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::FirefoxSearchPlugins - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::FirefoxSearchPlugins in FirefoxSearchPlugins.');
}


=head2 list

=cut

sub list :Local :Args(0) {
    my ( $self, $c ) = @_;

	my $model = $c->model('FirefoxSearchPlugins');
	$model->change_dir('plugins');	# go to where plugins are located
	my @files = $model->list(mode => 'files');
	map { $_ = $model->file($_)->basename } @files;	# remove path
	$c->stash->{ffsearchplugins} = \@files;
    $c->stash->{template} = "firefoxsearchplugins/list.tt";
}


=head2 get

=cut

sub get :Chained('/login/required') PathPart('firefoxsearchplugins/get') Args(1) {
    my ( $self, $c, $filename ) = @_;

	$c->stash(no_wrapper => 1);
	$c->response->content_type('application/opensearchdescription+xml');
	$c->stash->{template} = "firefoxsearchplugins/plugins/" . $filename;
}


sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Plugin nicht gefunden!";
    $c->detach('list');
}


=head1 AUTHOR

atacama development,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
