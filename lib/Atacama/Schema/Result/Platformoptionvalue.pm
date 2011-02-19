package Atacama::Schema::Result::Platformoptionvalue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Atacama::Schema::Result::Platformoptionvalue

=cut

__PACKAGE__->table("platformoptionvalues");

=head1 ACCESSORS

=head2 platformoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 publication_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "platformoptionkey_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "publication_id",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("platformoptionkey_id", "publication_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8j4fAgSMvgPyGaIIPTGg


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
