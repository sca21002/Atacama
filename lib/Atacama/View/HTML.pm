package Atacama::View::HTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    INCLUDE_PATH => [
        Atacama->path_to( 'root', 'base' ),
    ],
    render_die => 1,
    ENCODING     => 'utf-8',
    WRAPPER            => 'site/wrapper.tt',
);

=head1 NAME

Atacama::View::HTML - TT View for Atacama

=head1 DESCRIPTION

TT View for Atacama.

=head1 SEE ALSO

L<Atacama>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
