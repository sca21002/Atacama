use utf8;
package Atacama::Schema::Result::Platformoptionvalue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Platformoptionvalue

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

=head1 TABLE: C<platformoptionvalues>

=cut

__PACKAGE__->table("platformoptionvalues");

=head1 ACCESSORS

=head2 platformoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 publication_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value

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
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "publication_id",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</platformoptionkey_id>

=item * L</publication_id>

=back

=cut

__PACKAGE__->set_primary_key("platformoptionkey_id", "publication_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dkkyYYIPNOxDtN9eI6kf7w


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
