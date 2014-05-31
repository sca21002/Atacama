package Atacama::Schema::ResultSet::Titel;

# ABSTRACT: Result set for Titel  

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Carp;

sub get_new_result_as_href {
    my $self = shift;
    my $args = shift;

    my $row = $self->new_result($args);
    my $href = { map {$_, $row->$_ || ''} $row->columns };
    return $href;
}

1; # Magic true value required at end of module