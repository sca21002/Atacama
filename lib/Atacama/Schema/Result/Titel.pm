use utf8;
package Atacama::Schema::Result::Titel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Titel

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

=head1 TABLE: C<titel>

=cut

__PACKAGE__->table("titel");

=head1 ACCESSORS

=head2 order_id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 25

=head2 library_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 bvnr

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 katkey

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 mediennr

  data_type: 'char'
  is_nullable: 1
  size: 27

=head2 signatur

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 autor_avs

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 titel_avs

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 zusatz

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 bandangabe

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 verlagsort

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 verlag

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 erschjahr

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 issn

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 autor_uw

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 titel_uw

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 pages

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "order_id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 25 },
  "library_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "bvnr",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "katkey",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "mediennr",
  { data_type => "char", is_nullable => 1, size => 27 },
  "signatur",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "autor_avs",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "titel_avs",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "zusatz",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "bandangabe",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "verlagsort",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "verlag",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "erschjahr",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "issn",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "autor_uw",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "titel_uw",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "pages",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</order_id>

=back

=cut

__PACKAGE__->set_primary_key("order_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tJzcB6Xwig6508bZPP5cHQ

__PACKAGE__->add_columns(
    '+library_id' => { sisis => 'd01zweig' },                     
    '+mediennr'   => { sisis => 'd01gsi'   },
    '+signatur'   => { sisis => 'd01ort'   },
);

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->belongs_to(
    "library",
    "Atacama::Schema::Result::Library",
    { "foreign.library_id" => "self.library_id" }
);

use Data::Dumper;

sub titel_isbd {
    my $self = shift;

    my %data = $self->get_columns;
    foreach my $key (keys %data) {
        $data{$key} =~ s/^\s+|\s+$//g if $data{$key};
        $self->$key($data{$key});
    }

    my $titel_isbd;
    $titel_isbd .= $self->autor_uw if $self->autor_uw;
    $titel_isbd .= ' : ' if $self->autor_uw && $self->titel_uw;
    $titel_isbd .= $self->titel_uw if $self->titel_uw;
    $titel_isbd .= ' In: ' if $self->autor_uw || $self->titel_uw;
    $titel_isbd .= $self->autor_avs if $self->autor_avs;
    $titel_isbd .= ' : ' if $self->autor_avs;
    $titel_isbd .= $self->titel_avs if $self->titel_avs;
    $titel_isbd .= ' : ' if $self->zusatz;
    $titel_isbd .= $self->zusatz if $self->zusatz;
    $titel_isbd .= '. - ' if $self->verlagsort || $self->verlag || $self->erschjahr && !$self->bandangabe;
    $titel_isbd .= $self->verlagsort if $self->verlagsort;
    $titel_isbd .= ' : ' if $self->verlagsort && $self->verlag;
    $titel_isbd .= $self->verlag if $self->verlag;
    if ($self->bandangabe) {
        # $titel_isbd .= '/' . $self->bandangabe;
        if ($self->erschjahr) {
            $titel_isbd .=
                    ($self->erschjahr =~ /^\s*\(/ )
                        ? ' ' . $self->erschjahr
                        : ' (' . $self->erschjahr . ')'
        }
    } else {
      $titel_isbd .= ', ' if ($self->verlagsort || $self->verlag) && $self->erschjahr;
      $titel_isbd .= $self->erschjahr if $self->erschjahr;
    }
    # warn 'Titel: ' . $titel_isbd || '<kein Titel (ISBD)>';
    return $titel_isbd;
}


sub save {
    my $self = shift;
    my $params = shift;

    my %integer_type = ( smallint => 1, tinyint => 1, integer => 1, mediumint => 1);
    return unless (%$params);
    my %column;
    my $columns_info = __PACKAGE__->columns_info;

    my $relationships_info;
    my @relationships = __PACKAGE__->relationships;
    foreach my $relationship (@relationships) {
        $relationships_info->{$relationship} = 1;
    }

    while ( my($key, $val) = each %$params) {
        if (exists $columns_info->{$key}) {
            if (defined $val and $val eq ''
                and exists $integer_type{$columns_info->{$key}{data_type}}
            ){ $val = undef; }
           $column{$key} = $val;
        }
        elsif (exists $relationships_info->{$key}) {
            $self->$key->save($val);
        }
    }
    $self->update(\%column);
}

__PACKAGE__->meta->make_immutable;
1;
