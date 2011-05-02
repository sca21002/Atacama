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

	my @files = $c->model('FirefoxSearchPlugins')->list;
	my $file_list = join ':', @files;
    $c->response->body('Matched Atacama::Controller::FirefoxSearchPlugins in FirefoxSearchPlugins.' . $file_list);
}


=head2 list

=cut

sub list :Local :Args(0) {
    my ( $self, $c ) = @_;

	my @files = $c->model('FirefoxSearchPlugins')->list(mode => 'both');
	my $file_list = join ':', @files;
    $c->response->body($file_list);
}


=head2 pwd

=cut

sub pwd :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body($c->model('FirefoxSearchPlugins')->pwd);
}


=head1 AUTHOR

atacama development,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
