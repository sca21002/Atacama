package Atacama::View::PDF;

# ABSTRACT: TT View for PDF files in Atacama

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    DEBUG => 'plugins',
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

1; # Magic true value required at end of module

=head1 DESCRIPTION

TT View for PDF files in Atacama.

=head1 SEE ALSO

L<Atacama>