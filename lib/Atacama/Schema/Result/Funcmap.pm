package Atacama::Schema::Result::Funcmap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';


=head1 NAME

Atacama::Schema::Result::Funcmap

=cut

__PACKAGE__->table("funcmap");

=head1 ACCESSORS

=head2 funcid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 funcname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "funcid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "funcname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("funcid");
__PACKAGE__->add_unique_constraint("funcname", ["funcname"]);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-26 01:12:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Oy7xpzb0n0XgUTQ2jRM/ow


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
