package UBR::Sisis::Schema::Result::D01buch;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->table('sisis.d01buch');

__PACKAGE__->add_columns(
    'd01gsi',                          # Mediennummer
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 27,  },
    'd01ex',                           # Exemplarzaehlung
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 3,  },
    'd01zweig',                        # Zweigstelle   00 = Zentrale
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01entl',                         # Entleihbarkeit blank = ja , X = nein , L = Lesesaal			    B = Besonderer Lesesaal , W = Wochenende
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01bes',                          # Beschaedigt    blank = nein , X = ja
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01beilage',                      # Beilagen     > 0 => Beilagen vorhanden
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01mart',                         # Medienartenfeld => fuer Statistik
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01mcopyno',                      # Verweis zu Titel   oder PFL-Titeldatei
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01mtyp',                         # Medientyp  0 - 9
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01bg',                           # Benutzergruppe des Entleihers
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01bnr',                          # Benutzernummer
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 16,  },
    'd01status',                       # Buchstatus 0=frei, 2=bestellt, 4=entliehen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01skond',                        # Sonderkonditionen
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01av',                           # Ausleihdatum
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01rv',                           # Leihfristende
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01manz',                         # Anzahl Mahnungen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01vlanz',                        # Anzahl akt. Verlaengerungen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01vmanz',                        # Anzahl akt. exemplarspez. Vormerkungen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01afl',                          # Nummer der Aktiven Fernleihe
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 11,  },
    'd01bibbnr',                       # Benutzernummer der gebenden Bibliothek
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 15,  },
    'd01svjanz',                       # Statistikzaehler Anzahl Ausleihen Vorjahr
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01sljanz',                       # Statistikzaehler Anzahl Ausleihen lfd. Jahr
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01savanz',                       # Statistikzaehler Anzahl Ausleihen gesamt
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01svmanz',                       # Statistikzaehler Anzahl Vormerkungen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01ort',                          # Signatur - Standortfeld
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 40,  },
    'd01dbib',                         # derzeitige Bibliothek
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01mag',                          # Magazinkennzeichen
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01lbnr1',                        # letzer Benutzer
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 15,  },
    'd01lbnr2',                        # vorletzer Benutzer
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 15,  },
    'd01lrv1',                         # RV-Datum letzter Benutzer
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01lrv2',                         # RV-Datum    vorletzter Benutzer
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01abtlg',                        # Abteilung Standort
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01aort',                         # Ausgabeort Bestellung Vormerkung
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01bes_aort',                     # besonderer Ausgabeort Bestellung Vormerkung
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01vorab',                        # Kennzeichen, ob voraberinnert
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01kennz',                        # Kennzeichen intern
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01avl',                          # automatische Verl.
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01datbereit',                    # Datum der Bereitstellung BS   RV
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01uhrbereit',                    # Uhrzeit der Bereitstellung BS   RV
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 8,  },
    'd01svvjanz',                      # Statistikzaehler Anzahl Ausleihen Vorvorjahr
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01res1',                         # Reservekennzeichen 1 - seit A20 A30 belegt
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01res2',                         # Reservekennzeichen 2 - seit V3.5 belegt als Beilagenkennzeichen
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01res3',                         # Reservekennzeichen 3 - seit V3.0A30pl2 belegt als Briefkennzeichen  05 78
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01num1',                         # Reservezaehler 1
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01num2',                         # Reservezaehler 2
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01notiz',                        # Kennzeichen, ob Notizbucheintrag vorhanden
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01kostv',                        # Kennzeichen, ob kostenpflicht. Versand an Ben.
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01lfdbind',                      # Auftragsnummer fuer Buchbinderausleihe
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01aort_ls',                      # Kennzeichen, ob Ausgabeort Lesesaal ist J N
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01aufnahme',                     # Datum der Mediendatenaufnahme
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01afltext',                      # Variabler Text fuer AFL-Bestellung   Ausleihe
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 80,  },
    'd01datverlust',                   # Datum der Verlustmeldung
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01tour',                         # Bus: AV erfolgte auf Tour n
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01ort2',                         # 2. Signatur
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 40,  },
    'd01fl',                           # Ferleihrelevanz: 0: fernleihrelevant  default  1: bedingt fernleihrelevant  Praesenzbestand  2: kopierbar 3: nicht fernleihrelevant
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01standort',                     # Standort
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 6,  },
    'd01invkreis',                     # Inventarkreis aus Erwerbung
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 7,  },
    'd01invnr',                        # Inventarnummer aus Erwerbung
    {data_type  => 'INT', default_value => undef, is_nullable => 1, },
    'd01fussnoten',                    # Kennzeichen, ob Fussnoten vorhanden 0: keine 1: interne 2: externe 3: interne und externe
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01jahrupd',                      # Kennzeichen Update Jahresarbeiten
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01zfl',                          # Kennzeichen Bestellung AFL PFL aus ZFLSystem
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01verbund_ex_id',                # Exemplar-Id aus Verbund
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 26,  },
    'd01sigel',                        # Bibliothekssigel
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 21,  },
    'd01lav1',                         # Entleih-Datum letzter Benutzer
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01lav2',                         # Entleih-Datum vorletzter Benutzer
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01vmgelistet',                   # Kennzeichen, ob bereits fuer VM-Liste beruecksichtigt J N
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01istbeilage',                   # Kennzeichen, ob Medium eine Beilage ist J N
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01sig1sort',                     # Sortierform fuer Signatur 1
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 60,  },
    'd01sig2sort',                     # Sortierform fuer Signatur 2
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 60,  },
    'd01res4',                         # Reservekennzeichen 4
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01res5',                         # Reservekennzeichen 5
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01res6',                         # Reservekennzeichen 6
    {data_type  => 'CHAR', default_value => undef, is_nullable => 1, size => 1,  },
    'd01num3',                         # Reservezaehler 3
    {data_type  => 'SMALLINT', default_value => undef, is_nullable => 1, },
    'd01num4',                         # Reservezaehler 4
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01titlecatkey',                  # Verweis zu Titel-Katkey
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01usedcatkey',                   # Verweis zu bestelltem Titel-Katkey
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'd01rvbase',                       # Leihfristende der Erstleihfrist
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'd01vldate',                       # Datum der letzten Verlaengerung
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
);

__PACKAGE__->has_many(
    "titel",
    "UBR::Sisis::Schema::Result::TitelBuchKey",
    { "foreign.mcopyno" => "self.d01mcopyno" }
);


sub get_titel {
    my $self = shift;

    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->d01mcopyno;
    return $schema->resultset('TitelBuchKey')->search({mcopyno => \$where});    
}

1;
