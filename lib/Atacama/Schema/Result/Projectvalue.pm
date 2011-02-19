package Atacama::Schema::Result::Projectvalue;

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

Atacama::Schema::Result::Projectvalue

=cut

__PACKAGE__->table("projectvalues");

=head1 ACCESSORS

=head2 projectkey_id

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 ordersprojects_id

  data_type: 'mediumint'
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
  "projectkey_id",
  { data_type => "smallint", extra => { unsigned => 1 }, default_value => 0, is_nullable => 0 },
  "ordersprojects_id",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("projectkey_id", "ordersprojects_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sfHYE1IBRss95fhXAcD+Ag


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "projectkey",
    "Atacama::Schema::Result::Projectkey",
    { "projectkey_id" => "projectkey_id"}
);

__PACKAGE__->belongs_to(
    "ordersproject",
    "Atacama::Schema::Result::OrderProject",
    { "ordersprojects_id" => "ordersprojects_id"}
);


__PACKAGE__->meta->make_immutable;
1;
