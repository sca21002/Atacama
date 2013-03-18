use utf8;
package Atacama::Schema::Result::Scanoptionkey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Scanoptionkey

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

=head1 TABLE: C<scanoptionkeys>

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

=head1 PRIMARY KEY

=over 4

=item * L</scanoptionkey_id>

=back

=cut

__PACKAGE__->set_primary_key("scanoptionkey_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eSP72vgAONuI6oIQjI5c5w


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
