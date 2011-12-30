use utf8;
package Atacama::Schema::Result::Remark;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Remark

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

=head1 TABLE: C<remarks>

=cut

__PACKAGE__->table("remarks");

=head1 ACCESSORS

=head2 remark_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 order_id

  data_type: 'varchar'
  is_nullable: 0
  size: 25

=head2 status_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 login

  data_type: 'varchar'
  default_value: 'anonym'
  is_nullable: 0
  size: 100

=head2 content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "remark_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_id",
  { data_type => "varchar", is_nullable => 0, size => 25 },
  "status_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "login",
  {
    data_type => "varchar",
    default_value => "anonym",
    is_nullable => 0,
    size => 100,
  },
  "content",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</remark_id>

=back

=cut

__PACKAGE__->set_primary_key("remark_id");


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-30 14:03:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zm2Vs9JJT2TY287QJ1CXjw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
