package Atacama::Model::FirefoxSearchPlugins;

use strict;
use base 'Catalyst::Model::File';

__PACKAGE__->config(
    root_dir => Atacama->path_to(qw(root base firefoxsearchplugins)),
);

=head1 NAME

Atacama::Model::FirefoxSearchPlugins - Catalyst File Model

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

L<Catalyst::Model::File> Model storing files under
L<>

=head1 AUTHOR

atacama development,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
