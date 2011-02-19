package Atacama::Schema::Result::Scanoptionname;

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

Atacama::Schema::Result::Scanoptionname

=cut

__PACKAGE__->table("scanoptionnames");

=head1 ACCESSORS

=head2 value_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 scanoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "value_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "scanoptionkey_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("value_id", "scanoptionkey_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YzWXOpA9zeXu3w7a2gq9jg


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "scanoptionvalues",
    "Atacama::Schema::Result::Scanoptionvalue",
    {
        "foreign.value_id" => "self.value_id",
        "foreign.scanoptionkey_id" => "self.scanoptionkey_id",
    }
);

__PACKAGE__->belongs_to(
    "scanoptionkey",
    "Atacama::Schema::Result::Scanoptionkey",
    { "scanoptionkey_id" => "scanoptionkey_id" }
);   

__PACKAGE__->meta->make_immutable;
1;
