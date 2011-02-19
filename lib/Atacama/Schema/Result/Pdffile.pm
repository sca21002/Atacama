package Atacama::Schema::Result::Pdffile;

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

Atacama::Schema::Result::Pdffile

=cut

__PACKAGE__->table("pdffiles");

=head1 ACCESSORS

=head2 filename

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 filepath

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 order_id

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 ocr

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 pages

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 filesize

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 error

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "filename",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "filepath",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "ocr",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "pages",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "filesize",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "error",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("filename", "filepath");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mxMNVQVz4ofMUg5mULQuOQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->meta->make_immutable;
1;
