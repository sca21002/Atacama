package Atacama::View::JSON;

# ABSTRACT: TT View serving JSON in Atacama

use strict;
use base 'Catalyst::View::JSON';

__PACKAGE__->config( {
    expose_stash => [ qw( page total records rows json_data)]
} );

1; # Magic true value required at end of module

__END__

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

TT View serving JSON in Atacama




