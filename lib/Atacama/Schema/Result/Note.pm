use utf8;
package Atacama::Schema::Result::Note;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Note

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

=head1 TABLE: C<note>

=cut

__PACKAGE__->table("note");

=head1 ACCESSORS

=head2 jobid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 notekey

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'mediumblob'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "jobid",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "notekey",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "value",
  { data_type => "mediumblob", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</jobid>

=item * L</notekey>

=back

=cut

__PACKAGE__->set_primary_key("jobid", "notekey");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:11BI0wM7CRtDq15rR59tRA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
