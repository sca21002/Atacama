package Atacama::Schema::Result::Copyright;

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

Atacama::Schema::Result::Copyright

=cut

__PACKAGE__->table("copyrights");

=head1 ACCESSORS

=head2 copyright_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "copyright_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("copyright_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gnUgM7ctBxmWI6MNMRz8+Q


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "orders",
    "Atacama::Schema::Result::Order",
    { "foreign.copyright_id" => "self.copyright_id" }
);

__PACKAGE__->meta->make_immutable;
1;
