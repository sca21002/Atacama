package Atacama::Schema::Result::Branch;

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

Atacama::Schema::Result::Branch

=cut

__PACKAGE__->table("branches");

=head1 ACCESSORS

=head2 sisis_zweig

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 library_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "sisis_zweig",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "library_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("sisis_zweig");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ndjr9Q0g9QitAh3dmjzhwA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "library",
    "Atacama::Schema::Result::Library",
    { "foreign.library_id" => "self.library_id" }
);

__PACKAGE__->meta->make_immutable;
1;
