package Atacama::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
# use MooseX::NonMoose;  # Probleme mit anderen Modulen 
                         # sca21002, 20.02.2011
use namespace::autoclean;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g2ZC25IUa46QKFRktLfR1Q


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
