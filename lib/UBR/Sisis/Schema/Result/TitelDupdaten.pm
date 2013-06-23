use utf8;
package UBR::Sisis::Schema::Result::TitelDupdaten;

# Created by schemaloader.pl
#   Author: sca21002, sca21002@googlemail.com
#   Modifications by: knh11545, knh11545@ur.de


=head1 NAME

UBR::Sisis::Schema::Result::TitelDupdaten

=head1 DESCRIPTION

Duplizierung einiger Felder aus dem Titeldaten-BLOB in Tabelle titel_daten,
die damit per Datenbankbefehl zugänglich werden.

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


=head1 TABLE: C<titel_dupdaten>

=cut

__PACKAGE__->table('sisis.titel_dupdaten');



=head1 ACCESSORS



=head2 katkey

  data_type: 'INTEGER'
  is_nullable: 0
  default_value: undef
  

  Katalogschluessel


=head2 verfasser

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Kateg 100: Verfasser


=head2 autor_avs

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 321

  Kateg 100 200: Verf Urh aufbereitet


=head2 urheber

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Kateg 200:


=head2 titel

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Kateg 331:


=head2 titel_avs

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 321

  Kateg 331: Titel aufbereitet


=head2 zusatz

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 181

  Kateg 335:


=head2 bandangabe

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 81

  Kateg 089:


=head2 verlagsort

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 41

  Kateg 410:


=head2 verlag

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 81

  Kateg 412:


=head2 erschjahr

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 21

  Kateg 425:


=head2 isbn

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 18

  Kateg 540:


=head2 issn

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 10

  Kateg 543:


=head2 preis

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 11

  Kateg 542:


=head2 datumaufn

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Kateg 002:


=head2 datumaend

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Kateg 003:


=head2 schlagwort

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 81

  Kateg 902:


=head2 dupkateg_1

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 1. aus prof_dupdaten


=head2 dupkateg_2

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 2. aus prof_dupdaten


=head2 dupkateg_3

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 3. aus prof_dupdaten


=head2 dupkateg_4

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 4. aus prof_dupdaten


=head2 dupkateg_5

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 5. aus prof_dupdaten


=head2 dupkateg_6

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 6. aus prof_dupdaten


=head2 dupkateg_7

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 7. aus prof_dupdaten


=head2 dupkateg_8

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 8. aus prof_dupdaten


=head2 dupkateg_9

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie: 9. aus prof_dupdaten


=head2 dupkateg_10

  data_type: 'VARCHAR'
  is_nullable: 1
  default_value: undef
  size: 201

  Variable Kategorie:10. aus prof_dupdaten



=cut


__PACKAGE__->add_columns(
	# Katalogschluessel
	'katkey',                          
	{data_type  => 'INTEGER', default_value => undef, is_nullable => 0, },

	# Kateg 100: Verfasser
	'verfasser',                       
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Kateg 100 200: Verf Urh aufbereitet
	'autor_avs',                       
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 321,  },

	# Kateg 200:
	'urheber',                         
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Kateg 331:
	'titel',                           
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Kateg 331: Titel aufbereitet
	'titel_avs',                       
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 321,  },

	# Kateg 335:
	'zusatz',                          
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 181,  },

	# Kateg 089:
	'bandangabe',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 81,  },

	# Kateg 410:
	'verlagsort',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 41,  },

	# Kateg 412:
	'verlag',                          
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 81,  },

	# Kateg 425:
	'erschjahr',                       
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 21,  },

	# Kateg 540:
	'isbn',                            
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 18,  },

	# Kateg 543:
	'issn',                            
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 10,  },

	# Kateg 542:
	'preis',                           
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 11,  },

	# Kateg 002:
	'datumaufn',                       
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Kateg 003:
	'datumaend',                       
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Kateg 902:
	'schlagwort',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 81,  },

	# Variable Kategorie: 1. aus prof_dupdaten
	'dupkateg_1',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 2. aus prof_dupdaten
	'dupkateg_2',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 3. aus prof_dupdaten
	'dupkateg_3',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 4. aus prof_dupdaten
	'dupkateg_4',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 5. aus prof_dupdaten
	'dupkateg_5',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 6. aus prof_dupdaten
	'dupkateg_6',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 7. aus prof_dupdaten
	'dupkateg_7',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 8. aus prof_dupdaten
	'dupkateg_8',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie: 9. aus prof_dupdaten
	'dupkateg_9',                      
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

	# Variable Kategorie:10. aus prof_dupdaten
	'dupkateg_10',                     
	{data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 201,  },

);

__PACKAGE__->set_primary_key('katkey');

__PACKAGE__->meta->make_immutable;
1;
