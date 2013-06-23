use utf8;
package UBR::Sisis::Schema::Result::TitelVerbund;

# Created by schemaloader.pl
#   Author: sca21002, sca21002@googlemail.com
#   Modifications by: knh11545, knh11545@ur.de


=head1 NAME

UBR::Sisis::Schema::Result::TitelVerbund

=head1 DESCRIPTION

1:1-Verknüpfung des in SISIS für Titeldaten benutzten Identifiers katkey (Katalog-Nr.) zum 
Identifier BV-Nummer im Verbundkatalog.

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


=head1 TABLE: C<titel_verbund>

=cut

__PACKAGE__->table('sisis.titel_verbund');



=head1 ACCESSORS



=head2 katkey

  data_type: 'integer'
  is_nullable: 0
  default_value: undef
  

  Katkey aus titel_daten


=head2 verbundid

  data_type: 'varchar'
  is_nullable: 0
  default_value: undef
  size: 25

  Verbund ID



=cut


__PACKAGE__->add_columns(
	# Katkey aus titel_daten
	'katkey',                          
	{data_type  => 'integer', default_value => undef, is_nullable => 0, },

	# Verbund ID
	'verbundid',                       
	{data_type  => 'varchar', default_value => undef, is_nullable => 0, size => 25,  },

);

# Die unique constraints mag er so nicht. Warum? <-- Gilt diese Aussage noch? Ich teste es mal!

__PACKAGE__->set_primary_key('katkey');
# __PACKAGE__->add_unique_constraint( tv_verbundid => [ qw/ verbundid / ] );

__PACKAGE__->has_one(
    'titel_buch_key',
    'UBR::Sisis::Schema::Result::TitelBuchKey',
    { 'foreign.katkey' => 'self.katkey' },
    { is_foreign_key_constraint => 0 },
);


sub get_titel {
    my $self = shift;
    
    my %titel = $self->get_columns;
    
    my $schema = $self->result_source->schema; 
    my $where = '= ' . $self->katkey;
    my $titel_buch_key = $schema->resultset('TitelBuchKey')->search(
        { katkey => \$where },
    )->first;
    my $titel_href = $titel_buch_key->get_titel_dup_daten();
    $where = '= ' . $titel_buch_key->mcopyno;
    my $buch = $schema->resultset('D01buch')->search(
        { d01mcopyno => \$where },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    )->first;
    return { %titel, %$titel_href, %$buch };
}

__PACKAGE__->meta->make_immutable;
1;
