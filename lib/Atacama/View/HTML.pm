package Atacama::View::HTML;

# ABSTRACT: Default TT View in Atacama

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

1; # Magic true value required at end of module

=head1 DESCRIPTION

Default TT View in Atacama

=head1 SEE ALSO

L<Atacama>