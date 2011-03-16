package UBR::Sisis::Schema;

use strict;
use warnings;

use Moose;
# use MooseX::NonMoose;  # Probleme mit anderen Modulen 
                         # sca21002, 20.02.2011
use namespace::autoclean;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;
1;
