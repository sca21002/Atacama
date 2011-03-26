package Atacama::Schema::Result::Note;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';


=head1 NAME

Atacama::Schema::Result::Note

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
__PACKAGE__->set_primary_key("jobid", "notekey");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-26 01:12:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zN168QX7c+xiQAxAUgCjOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
