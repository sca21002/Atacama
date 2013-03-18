use utf8;
package Atacama::Schema::Result::Pdffile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Pdffile

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<pdffiles>

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

=head1 PRIMARY KEY

=over 4

=item * L</filename>

=item * L</filepath>

=back

=cut

__PACKAGE__->set_primary_key("filename", "filepath");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KcXEutuPr0E7MvO6iIocSA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->meta->make_immutable;
1;
