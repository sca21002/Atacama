use utf8;
package Atacama::Schema::Result::Scanner;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Scanner

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

=head1 TABLE: C<scanners>

=cut

__PACKAGE__->table("scanners");

=head1 ACCESSORS

=head2 scanner_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_auto_increment: 1
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
  "scanner_id",
  {
    data_type => "tinyint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</scanner_id>

=back

=cut

__PACKAGE__->set_primary_key("scanner_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<scanner_scanners>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("scanner_scanners", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1WBjk4VhdKlW/kU0e6wF+A


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "scanparameters",
    "Atacama::Schema::Result::Scanparameter",
    { "foreign.scanner_id" => "self.scanner_id" }
);

__PACKAGE__->has_many(
    "scanoptionkeys",
    "Atacama::Schema::Result::Scanoptionkey",
    { "foreign.scanner_id" => "self.scanner_id" }
);


__PACKAGE__->meta->make_immutable;
1;
