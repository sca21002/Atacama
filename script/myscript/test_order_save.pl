#!/usr/bin/perl -w
use strict;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Atacama::Schema;
use Carp;
use Data::Dumper;

my $params = {
    'remark' => 'etravel: 14 Bilder
2 Karten',
    'titel' => {
                 'autor_uw' => '',
                 'bvnr' => 'BV011304001',
                 'library_id' => '3',
                 'katkey' => '0',
                 'signatur' => '999/2Hist.pol.634(1 ',
                 'mediennr' => '069027182904',
                 'titel_uw' => '',
                 'pages' => ''
               },
    'orders_projects' => [
                          
                           {
                             'projectoptions' => [
                                                   {
                                                     'projectkey_id' => '1',
                                                     'value' => ''
                                                   }
                                                 ],
                             'project_id' => '1',
                             'ordersprojects_id' => '2188'
                           },
                           {
                             'ordersprojects_id' => '4658',
                             'project_id' => '11'
                           },
                           {
                             'project_id' => ''
                           }
                         ],
    'publications' => [
                        {
                          'publicationoptions' => [
                                                    {
                                                      'value' => '879612',
                                                      'platformoptionkey_id' => '1'
                                                    }
                                                  ],
                          'publication_id' => '147',
                          'DELETED' => '1',
                          'platform_id' => '1'
                        },
                        {
                          'platform_id' => ''
                        }
                      ],
    'scanparameters' => [
                          {
                            'format_id' => '2',
                            'range' => 'Text',
                            'scanner_id' => '6',
                            'scanparameter_id' => '1033',
                            'resolution_id' => '1'
                          },
                          {
                            'format_id' => '2',
                            'scanoptions' => [
                                               {
                                                 'scanoptionkey_id' => '2',
                                                 'value_id' => '1'
                                               }
                                             ],
                            'range' => "Karten, zuerg\x{e4}nzende Textseiten und Einband",
                            'scanparameter_id' => '1034',
                            'scanner_id' => '2',
                            'resolution_id' => '1'
                          },
                          {
                            'format_id' => '',
                            'range' => '',
                            'resolution_id' => '',
                            'scanner_id' => '5'
                          }
                        ],
    'copyright_id' => "",
    'status_id' => '9',
    'documenttype_id' => '1',
    'control' => 'pen 31.3.07'
};

my $dsn_atacama = 'dbi:mysql:atacama';
my $user_atacama = 'db_user';
my $password_atacama =  'db_password';
my $param_atacama = {
    AutoCommit => 1,
    mysql_enable_utf8   => 1,
};

my $schema_atacama = Atacama::Schema->connect(
    $dsn_atacama,
    $user_atacama,
    $password_atacama,
    $param_atacama,
);

my $order = $schema_atacama->resultset('Order')->find('ubr02862');
carp "Gefunden: " . $order->modification_date;
$order->save($params);
