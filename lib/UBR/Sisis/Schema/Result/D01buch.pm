use utf8;
package UBR::Sisis::Schema::Result::D01buch;

# Created by schemaloader.pl
#   Author: sca21002, sca21002@googlemail.com
#   Modifications by: knh11545, knh11545@ur.de

=head1 NAME

UBR::Sisis::Schema::Result::D01buch

=head1 DESCRIPTION

Buchdatei

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


=head1 TABLE: C<d01buch>

=cut

__PACKAGE__->table('sisis.d01buch');



=head1 ACCESSORS



=head2 d01gsi

  data_type: 'char'
  is_nullable: 0
  default_value: undef
  size: 27

  Mediennummer


=head2 d01ex

  data_type: 'char'
  is_nullable: 0
  default_value: undef
  size: 3

  Exemplarzaehlung


=head2 d01zweig

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Zweigstelle 00 = Zentrale


=head2 d01entl

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Entleihbarkeit blank = ja , X = nein , L = Lesesaal B = Besonderer Lesesaal , W = Wochenende


=head2 d01bes

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Beschaedigt blank = nein , X = ja


=head2 d01beilage

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Beilagen > 0 => Beilagen vorhanden


=head2 d01mart

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Medienartenfeld => fuer Statistik


=head2 d01mcopyno

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Verweis zu Titel oder PFL-Titeldatei


=head2 d01mtyp

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Medientyp 0 - 9


=head2 d01bg

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Benutzergruppe des Entleihers


=head2 d01bnr

  data_type: 'varchar'
  is_nullable: 1
  default_value: undef
  size: 16

  Benutzernummer


=head2 d01status

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Buchstatus 0=frei, 2=bestellt, 4=entliehen


=head2 d01skond

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Sonderkonditionen


=head2 d01av

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Ausleihdatum


=head2 d01rv

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Leihfristende


=head2 d01manz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Anzahl Mahnungen


=head2 d01vlanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Anzahl akt. Verlaengerungen


=head2 d01vmanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Anzahl akt. exemplarspez. Vormerkungen


=head2 d01afl

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 22

  Nummer der Aktiven Fernleihe


=head2 d01bibbnr

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 15

  Benutzernummer der gebenden Bibliothek


=head2 d01svjanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Statistikzaehler Anzahl Ausleihen Vorjahr


=head2 d01sljanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Statistikzaehler Anzahl Ausleihen lfd. Jahr


=head2 d01savanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Statistikzaehler Anzahl Ausleihen gesamt


=head2 d01svmanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Statistikzaehler Anzahl Vormerkungen


=head2 d01ort

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 160

  Signatur - Standortfeld


=head2 d01dbib

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  derzeitige Bibliothek


=head2 d01mag

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Magazinkennzeichen


=head2 d01lbnr1

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 15

  letzer Benutzer


=head2 d01lbnr2

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 15

  vorletzer Benutzer


=head2 d01lrv1

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  RV-Datum letzter Benutzer


=head2 d01lrv2

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  RV-Datum vorletzter Benutzer


=head2 d01abtlg

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Abteilung Standort


=head2 d01aort

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Ausgabeort Bestellung Vormerkung


=head2 d01bes_aort

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  besonderer Ausgabeort Bestellung Vormerkung


=head2 d01vorab

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob voraberinnert


=head2 d01kennz

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen intern


=head2 d01avl

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  automatische Verl.


=head2 d01datbereit

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Datum der Bereitstellung BS RV


=head2 d01uhrbereit

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 8

  Uhrzeit der Bereitstellung BS RV


=head2 d01svvjanz

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Statistikzaehler Anzahl Ausleihen Vorvorjahr


=head2 d01res1

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 1 - seit A20 A30 belegt


=head2 d01res2

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 2 - seit V3.5 belegt als Beilagenkennzeichen


=head2 d01res3

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 3 - seit V3.0A30pl2 belegt als Briefkennzeichen 05 78


=head2 d01num1

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Reservezaehler 1


=head2 d01num2

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Reservezaehler 2


=head2 d01notiz

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob Notizbucheintrag vorhanden


=head2 d01kostv

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob kostenpflicht. Versand an Ben.


=head2 d01lfdbind

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Auftragsnummer fuer Buchbinderausleihe


=head2 d01aort_ls

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob Ausgabeort Lesesaal ist J N


=head2 d01aufnahme

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Datum der Mediendatenaufnahme


=head2 d01afltext

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 80

  Variabler Text fuer AFL-Bestellung Ausleihe


=head2 d01datverlust

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Datum der Verlustmeldung


=head2 d01tour

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Bus: AV erfolgte auf Tour n


=head2 d01ort2

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 160

  2. Signatur


=head2 d01fl

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Ferleihrelevanz: 0: fernleihrelevant default 1: bedingt fernleihrelevant Praesenzbestand 2: kopierbar 3: nicht fernleihrelevant


=head2 d01standort

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 6

  Standort


=head2 d01invkreis

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 14

  Inventarkreis aus Erwerbung


=head2 d01invnr

  data_type: 'int'
  is_nullable: 1
  default_value: undef
  

  Inventarnummer aus Erwerbung


=head2 d01fussnoten

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Kennzeichen, ob Fussnoten vorhanden 0: keine 1: extern 2: intern 3: interne und externe


=head2 d01jahrupd

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Kennzeichen Update Jahresarbeiten


=head2 d01zfl

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen Bestellung AFL PFL aus ZFLSystem


=head2 d01verbund_ex_id

  data_type: 'varchar'
  is_nullable: 1
  default_value: undef
  size: 26

  Exemplar-Id aus Verbund


=head2 d01sigel

  data_type: 'varchar'
  is_nullable: 1
  default_value: undef
  size: 21

  Bibliothekssigel


=head2 d01lav1

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Entleih-Datum letzter Benutzer


=head2 d01lav2

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Entleih-Datum vorletzter Benutzer


=head2 d01vmgelistet

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob bereits fuer VM-Liste beruecksichtigt J N


=head2 d01istbeilage

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Kennzeichen, ob Medium eine Beilage ist J N


=head2 d01sig1sort

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 120

  Sortierform fuer Signatur 1


=head2 d01sig2sort

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 120

  Sortierform fuer Signatur 2


=head2 d01res4

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 4


=head2 d01res5

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 5


=head2 d01res6

  data_type: 'char'
  is_nullable: 1
  default_value: undef
  size: 1

  Reservekennzeichen 6


=head2 d01num3

  data_type: 'smallint'
  is_nullable: 1
  default_value: undef
  

  Reservezaehler 3 verwendet fuer Altersbeschraenkung FSK


=head2 d01num4

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Reservezaehler 4


=head2 d01titlecatkey

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Verweis zu Titel-Katkey


=head2 d01usedcatkey

  data_type: 'integer'
  is_nullable: 1
  default_value: undef
  

  Verweis zu bestelltem Titel-Katkey


=head2 d01rvbase

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Leihfristende der Erstleihfrist


=head2 d01vldate

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  

  Datum der letzten Verlaengerung



=cut


__PACKAGE__->add_columns(
	# Mediennummer
	'd01gsi',                          
	{data_type  => 'char', default_value => undef, is_nullable => 0, size => 27,  },

	# Exemplarzaehlung
	'd01ex',                           
	{data_type  => 'char', default_value => undef, is_nullable => 0, size => 3,  },

	# Zweigstelle 00 = Zentrale
	'd01zweig',                        
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Entleihbarkeit blank = ja , X = nein , L = Lesesaal B = Besonderer Lesesaal , W = Wochenende
	'd01entl',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Beschaedigt blank = nein , X = ja
	'd01bes',                          
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Beilagen > 0 => Beilagen vorhanden
	'd01beilage',                      
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Medienartenfeld => fuer Statistik
	'd01mart',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Verweis zu Titel oder PFL-Titeldatei
	'd01mcopyno',                      
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Medientyp 0 - 9
	'd01mtyp',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Benutzergruppe des Entleihers
	'd01bg',                           
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Benutzernummer
	'd01bnr',                          
	{data_type  => 'varchar', default_value => undef, is_nullable => 1, size => 16,  },

	# Buchstatus 0=frei, 2=bestellt, 4=entliehen
	'd01status',                       
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Sonderkonditionen
	'd01skond',                        
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Ausleihdatum
	'd01av',                           
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Leihfristende
	'd01rv',                           
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Anzahl Mahnungen
	'd01manz',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Anzahl akt. Verlaengerungen
	'd01vlanz',                        
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Anzahl akt. exemplarspez. Vormerkungen
	'd01vmanz',                        
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Nummer der Aktiven Fernleihe
	'd01afl',                          
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 22,  },

	# Benutzernummer der gebenden Bibliothek
	'd01bibbnr',                       
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 15,  },

	# Statistikzaehler Anzahl Ausleihen Vorjahr
	'd01svjanz',                       
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Statistikzaehler Anzahl Ausleihen lfd. Jahr
	'd01sljanz',                       
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Statistikzaehler Anzahl Ausleihen gesamt
	'd01savanz',                       
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Statistikzaehler Anzahl Vormerkungen
	'd01svmanz',                       
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Signatur - Standortfeld
	'd01ort',                          
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 160,  },

	# derzeitige Bibliothek
	'd01dbib',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Magazinkennzeichen
	'd01mag',                          
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# letzer Benutzer
	'd01lbnr1',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 15,  },

	# vorletzer Benutzer
	'd01lbnr2',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 15,  },

	# RV-Datum letzter Benutzer
	'd01lrv1',                         
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# RV-Datum vorletzter Benutzer
	'd01lrv2',                         
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Abteilung Standort
	'd01abtlg',                        
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Ausgabeort Bestellung Vormerkung
	'd01aort',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# besonderer Ausgabeort Bestellung Vormerkung
	'd01bes_aort',                     
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Kennzeichen, ob voraberinnert
	'd01vorab',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Kennzeichen intern
	'd01kennz',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# automatische Verl.
	'd01avl',                          
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Datum der Bereitstellung BS RV
	'd01datbereit',                    
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Uhrzeit der Bereitstellung BS RV
	'd01uhrbereit',                    
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 8,  },

	# Statistikzaehler Anzahl Ausleihen Vorvorjahr
	'd01svvjanz',                      
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Reservekennzeichen 1 - seit A20 A30 belegt
	'd01res1',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservekennzeichen 2 - seit V3.5 belegt als Beilagenkennzeichen
	'd01res2',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservekennzeichen 3 - seit V3.0A30pl2 belegt als Briefkennzeichen 05 78
	'd01res3',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservezaehler 1
	'd01num1',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Reservezaehler 2
	'd01num2',                         
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Kennzeichen, ob Notizbucheintrag vorhanden
	'd01notiz',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Kennzeichen, ob kostenpflicht. Versand an Ben.
	'd01kostv',                        
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Auftragsnummer fuer Buchbinderausleihe
	'd01lfdbind',                      
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Kennzeichen, ob Ausgabeort Lesesaal ist J N
	'd01aort_ls',                      
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Datum der Mediendatenaufnahme
	'd01aufnahme',                     
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Variabler Text fuer AFL-Bestellung Ausleihe
	'd01afltext',                      
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 80,  },

	# Datum der Verlustmeldung
	'd01datverlust',                   
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Bus: AV erfolgte auf Tour n
	'd01tour',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# 2. Signatur
	'd01ort2',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 160,  },

	# Ferleihrelevanz: 0: fernleihrelevant default 1: bedingt fernleihrelevant Praesenzbestand 2: kopierbar 3: nicht fernleihrelevant
	'd01fl',                           
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Standort
	'd01standort',                     
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 6,  },

	# Inventarkreis aus Erwerbung
	'd01invkreis',                     
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 14,  },

	# Inventarnummer aus Erwerbung
	'd01invnr',                        
	{data_type  => 'int', default_value => undef, is_nullable => 1, },

	# Kennzeichen, ob Fussnoten vorhanden 0: keine 1: extern 2: intern 3: interne und externe
	'd01fussnoten',                    
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Kennzeichen Update Jahresarbeiten
	'd01jahrupd',                      
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Kennzeichen Bestellung AFL PFL aus ZFLSystem
	'd01zfl',                          
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Exemplar-Id aus Verbund
	'd01verbund_ex_id',                
	{data_type  => 'varchar', default_value => undef, is_nullable => 1, size => 26,  },

	# Bibliothekssigel
	'd01sigel',                        
	{data_type  => 'varchar', default_value => undef, is_nullable => 1, size => 21,  },

	# Entleih-Datum letzter Benutzer
	'd01lav1',                         
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Entleih-Datum vorletzter Benutzer
	'd01lav2',                         
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Kennzeichen, ob bereits fuer VM-Liste beruecksichtigt J N
	'd01vmgelistet',                   
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Kennzeichen, ob Medium eine Beilage ist J N
	'd01istbeilage',                   
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Sortierform fuer Signatur 1
	'd01sig1sort',                     
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 120,  },

	# Sortierform fuer Signatur 2
	'd01sig2sort',                     
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 120,  },

	# Reservekennzeichen 4
	'd01res4',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservekennzeichen 5
	'd01res5',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservekennzeichen 6
	'd01res6',                         
	{data_type  => 'char', default_value => undef, is_nullable => 1, size => 1,  },

	# Reservezaehler 3 verwendet fuer Altersbeschraenkung FSK
	'd01num3',                         
	{data_type  => 'smallint', default_value => undef, is_nullable => 1, },

	# Reservezaehler 4
	'd01num4',                         
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Verweis zu Titel-Katkey
	'd01titlecatkey',                  
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Verweis zu bestelltem Titel-Katkey
	'd01usedcatkey',                   
	{data_type  => 'integer', default_value => undef, is_nullable => 1, },

	# Leihfristende der Erstleihfrist
	'd01rvbase',                       
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

	# Datum der letzten Verlaengerung
	'd01vldate',                       
	{data_type  => 'datetime', default_value => undef, is_nullable => 1, },

);

__PACKAGE__->set_primary_key( qw( d01gsi d01ex ) );


__PACKAGE__->has_many(
	"titel_buch_keys",
	"UBR::Sisis::Schema::Result::TitelBuchKey",
	{ "foreign.mcopyno" => "self.d01mcopyno" },
	{}
);

__PACKAGE__->belongs_to(
	"titlecatkey",
	"UBR::Sisis::Schema::Result::TitelDupdaten",
	{ "foreign.katkey" => "self.d01titlecatkey" },
	{ is_foreign_key_constraint => 0 }
);

__PACKAGE__->belongs_to(
	"usedcatkey",
	"UBR::Sisis::Schema::Result::TitelDupdaten",
	{ "foreign.katkey" => "self.d01usedcatkey" },
	{ is_foreign_key_constraint => 0 }
);

#__PACKAGE__->belongs_to(
#	"d02ben",
#	"UBR::Sisis::Schema::Result::D02ben",
#	{ "foreign.d02bnr" => "self.d01bnr" },
#	{ join_type => 'left' }
#);

sub get_titel {
    my $self = shift;

    my %buch = $self->get_columns;
    
    my @titel;
    foreach my $titel ($self->titel_buch_keys) {
        my $titel_href = $titel->get_titel_dup_daten();
        $titel_href->{bvnr} = $titel->get_bvnr;
        push @titel, { %buch, %$titel_href };  
    }
    return \@titel;
}

__PACKAGE__->meta->make_immutable;
1;
