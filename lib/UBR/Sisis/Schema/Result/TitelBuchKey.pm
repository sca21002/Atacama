use utf8;
package UBR::Sisis::Schema::Result::TitelBuchKey;

# Created by schemaloader.pl
#   Author: sca21002, sca21002@googlemail.com
#   Modifications by: knh11545, knh11545@ur.de


=head1 NAME

UBR::Sisis::Schema::Result::TitelBuchKey

=head1 DESCRIPTION

Tabelle zur Verknüpfung von Exemplaren in d01buch zu Titeldatensätzen, 
die per katkey identifiziert werden. Wegen Bindeeinheiten muss es 
diese n:m-Verknüpfung geben.

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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");


=head1 TABLE: C<titel_buch_key>

=cut

__PACKAGE__->table('sisis.titel_buch_key');



=head1 ACCESSORS



=head2 katkey

  data_type: 'integer'
  is_nullable: 0
  default_value: undef
  

  Katkey aus titel_daten


=head2 mcopyno

  data_type: 'integer'
  is_nullable: 0
  default_value: undef
  

  Circulation-Key aus titel_daten = d01buch.d01mcopyno


=head2 seqnr

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Rangfolge der Titel innerhalb einer Bindeeinheit



=cut


__PACKAGE__->add_columns(
	# Katkey aus titel_daten
	'katkey',                          
	{data_type  => 'integer', default_value => undef, is_nullable => 0, },

	# Circulation-Key aus titel_daten = d01buch.d01mcopyno
	'mcopyno',                         
	{data_type  => 'integer', default_value => undef, is_nullable => 0, },

	# Rangfolge der Titel innerhalb einer Bindeeinheit
	'seqnr',                           
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

);

__PACKAGE__->set_primary_key( qw( katkey mcopyno ) );

__PACKAGE__->belongs_to(
    'd01buch',
    'UBR::Sisis::Schema::Result::D01buch',
    { 'foreign.d01mcopyno' => 'self.mcopyno' },
    { is_foreign_key_constraint => 0 },
);

__PACKAGE__->might_have(
    'titel_verbund',
    'UBR::Sisis::Schema::Result::TitelVerbund',
    { 'foreign.katkey' => 'self.katkey' },
    {
        is_foreign_key_constraint => 0, 
    },
);

__PACKAGE__->belongs_to(
    'titel_dupdaten',
    'UBR::Sisis::Schema::Result::TitelDupdaten',
    { 'foreign.katkey' => 'self.katkey' },
    { is_foreign_key_constraint => 0 },
);


sub get_titel_dup_daten {
    my $self = shift;
    
    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->katkey;
    return $schema->resultset('TitelDupdaten')->search(
        { katkey => \$where },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    )->first;
}    

sub get_bvnr {
    my $self = shift;
    
    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->katkey;
    my $titel_buch_key =
        $schema->resultset('TitelVerbund')->search({katkey => \$where})->first;
    return $titel_buch_key->verbundid if $titel_buch_key;    
}

sub get_titel {
    my $self = shift;
    
    my $titel_href = $self->get_titel_dup_daten();
    $titel_href->{bvnr} = $self->get_bvnr || 'BV000000000';
    return $titel_href;
}

__PACKAGE__->meta->make_immutable;
1;
