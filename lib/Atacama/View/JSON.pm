package Atacama::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

=head1 NAME

Atacama::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->config({ expose_stash => [ qw( page total records rows json_data)] });

1;
