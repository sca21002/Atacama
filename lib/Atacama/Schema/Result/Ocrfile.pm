use utf8;
package Atacama::Schema::Result::Ocrfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Ocrfile

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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<ocrfiles>

=cut

__PACKAGE__->table("ocrfiles");

=head1 ACCESSORS

=head2 filename

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 filepath

  data_type: 'varchar'
  default_value: (empty string)
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

=head2 filesize

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 md5

  data_type: 'varbinary'
  is_nullable: 1
  size: 32

=head2 error

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "filename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "filepath",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "volume",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "format",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "filesize",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "md5",
  { data_type => "varbinary", is_nullable => 1, size => 32 },
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


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-02-10 09:09:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iPGquvhzUNNjQaOeoamrNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
