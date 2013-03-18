use utf8;
package Atacama::Schema::Result::Funcmap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Funcmap

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

=head1 TABLE: C<funcmap>

=cut

__PACKAGE__->table("funcmap");

=head1 ACCESSORS

=head2 funcid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 funcname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "funcid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "funcname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</funcid>

=back

=cut

__PACKAGE__->set_primary_key("funcid");

=head1 UNIQUE CONSTRAINTS

=head2 C<funcname>

=over 4

=item * L</funcname>

=back

=cut

__PACKAGE__->add_unique_constraint("funcname", ["funcname"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6hjZNojeAKt74jrzc717jg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
