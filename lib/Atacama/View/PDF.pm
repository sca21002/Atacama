package Atacama::View::PDF;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

Atacama::View::PDF - TT View for Atacama

=head1 DESCRIPTION

TT View for Atacama.

=head1 SEE ALSO

L<Atacama>

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
