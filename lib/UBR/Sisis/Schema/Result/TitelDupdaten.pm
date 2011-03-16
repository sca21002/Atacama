package UBR::Sisis::Schema::Result::TitelDupdaten;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->table('sisis.titel_dupdaten');

__PACKAGE__->add_columns(
    'katkey',                          # Katalogschluessel
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'verfasser',                       # Kateg 100: Verfasser
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'autor_avs',                       # Kateg 100 200: Verf Urh aufbereitet
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 161,  },
    'urheber',                         # Kateg 200:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'titel',                           # Kateg 331:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'titel_avs',                       # Kateg 331: Titel aufbereitet
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 161,  },
    'zusatz',                          # Kateg 335:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 91,  },
    'bandangabe',                      # Kateg 089:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 41,  },
    'verlagsort',                      # Kateg 410:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 21,  },
    'verlag',                          # Kateg 412:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 41,  },
    'erschjahr',                       # Kateg 425:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 11,  },
    'isbn',                            # Kateg 540:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 18,  },
    'issn',                            # Kateg 543:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 10,  },
    'preis',                           # Kateg 542:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 11,  },
    'datumaufn',                       # Kateg 002:
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'datumaend',                       # Kateg 003:
    {data_type  => 'DATETIME', default_value => undef, is_nullable => 1, },
    'schlagwort',                      # Kateg 902:
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 41,  },
    'dupkateg_1',                      # Variable Kategorie: 1. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_2',                      # Variable Kategorie: 2. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_3',                      # Variable Kategorie: 3. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_4',                      # Variable Kategorie: 4. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_5',                      # Variable Kategorie: 5. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_6',                      # Variable Kategorie: 6. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_7',                      # Variable Kategorie: 7. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_8',                      # Variable Kategorie: 8. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_9',                      # Variable Kategorie: 9. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
    'dupkateg_10',                     # Variable Kategorie:10. aus prof_dupdaten
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 101,  },
);

1;
