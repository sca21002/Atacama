package Atacama::Schema::Result::Scanoptionkey;

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

Atacama::Schema::Result::Scanoptionkey

=cut

__PACKAGE__->table("scanoptionkeys");

=head1 ACCESSORS

=head2 scanoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 scanner_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 sorting

  data_type: 'tinyint'
  is_nullable: 1

=head2 skey

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "scanoptionkey_id",
  {
    data_type => "smallint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "scanner_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "sorting",
  { data_type => "tinyint", is_nullable => 1 },
  "skey",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("scanoptionkey_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OzIVVpSTh26+2b4rk7OWcQ


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->belongs_to(
    "scanner",
    "Atacama::Schema::Result::Scanner",
    { "foreign.scanner_id" => "self.scanner_id" }
);

__PACKAGE__->has_many(
    "scanoptionvalues",
    "Atacama::Schema::Result::Scanoptionvalue",
    { "foreign.scanoptionkey_id" => "self.scanoptionkey_id" }
);

__PACKAGE__->has_many(
    "scanoptionnames",
    "Atacama::Schema::Result::Scanoptionname",
    { "foreign.scanoptionkey_id" => "self.scanoptionkey_id" }
);

__PACKAGE__->meta->make_immutable;
1;
