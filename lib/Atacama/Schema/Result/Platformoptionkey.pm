use utf8;
package Atacama::Schema::Result::Platformoptionkey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Platformoptionkey

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

=head1 TABLE: C<platformoptionkeys>

=cut

__PACKAGE__->table("platformoptionkeys");

=head1 ACCESSORS

=head2 platformoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 platform_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 sorting

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 pkey

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
  {
    data_type => "smallint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "platform_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "sorting",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "pkey",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</platformoptionkey_id>

=back

=cut

__PACKAGE__->set_primary_key("platformoptionkey_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cFxbCpcgpnDznJQavL+ziw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "platform",
    "Atacama::Schema::Result::Platform",
    { "foreign.platform_id" => "self.platform_id" }
);

__PACKAGE__->has_many(
    "platformoptionvalues",
    "Atacama::Schema::Result::Platformoptionvalue",
    { "foreign.platformoptionkey_id" => "self.platformoptionkey_id" }
);


__PACKAGE__->meta->make_immutable;
1;
