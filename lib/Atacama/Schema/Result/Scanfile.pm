package Atacama::Schema::Result::Scanfile;

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

Atacama::Schema::Result::Scanfile

=cut

__PACKAGE__->table("scanfiles");

=head1 ACCESSORS

=head2 filename

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 filepath

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 volume

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 order_id

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 format

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 colortype

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 resolution

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 height_px

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 width_px

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 filesize

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 md5

  data_type: 'varbinary'
  is_nullable: 1
  size: 32

=head2 icc_profile

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 error

  data_type: 'text'
  is_nullable: 1

=head2 deleted

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "filename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "filepath",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "volume",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "format",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "colortype",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "resolution",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "height_px",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "width_px",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "filesize",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "md5",
  { data_type => "varbinary", is_nullable => 1, size => 32 },
  "icc_profile",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "error",
  { data_type => "text", is_nullable => 1 },
  "deleted",
  { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("filename", "filepath");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OgBTleGH1mN+MWgU54cARw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->has_many(
    "publications",
    "Atacama::Schema::Result::Publication",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->meta->make_immutable;
1;
