#!/usr/bin/perl -w
use strict;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
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
                       'signatur' => '999/2Hist.pol.634(1',
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
                                 }
                               ],
          'scanparameters' => [
                                {
                                  'format_id' => '2',
                                  'scope' => 'Text',
                                  'scanner_id' => '6',
                                  'scanparameter_id' => '1033',
                                  'resolution_id' => '2'
                                },
                                {
                                  'format_id' => '2',
                                  'scanoptions' => [
                                                     {
                                                       'scanoptionkey_id' => '2',
                                                       'value_id' => '3'
                                                     }
                                                   ],
                                  'scope' => "Karten, zuerg\x{e4}nzende Textseiten und Einband",
                                  'scanparameter_id' => '1034',
                                  'scanner_id' => '2',
                                  'resolution_id' => '1'
                                },
                                {
                                  'format_id' => '',
                                  'scanoptions' => [
                                                     {
                                                       'scanoptionkey_id' => '1',
                                                       'value_id' => '1'
                                                     }
                                                   ],
                                  'scope' => '',
                                  'scanparameter_id' => '6430',
                                  'scanner_id' => '1',
                                  'resolution_id' => ''
                                },
                                {
                                  'formats' => '',
                                  'scanoptions' => [
                                                     {
                                                       'value_id' => ''
                                                     }
                                                   ],
                                  'scope' => '',
                                  'resolutions' => '',
                                  'scanner_id' => '2',
                                  'scanparameter_id' => ''
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
                                'platform_id' => '1'
                              }
                            ],
          'copyright_id' => '',
          'status_id' => '9',
          'documenttype_id' => '1',
          'control' => 'pen 31.3.09'
        };



#my $params = {
#    'remark' => 'etravel: 14 Bilder
#2 Karten',
#    'titel' => {
#                 'autor_uw' => '',
#                 'bvnr' => 'BV011304001',
#                 'library_id' => '3',
#                 'katkey' => '0',
#                 'signatur' => '999/2Hist.pol.634(1 ',
#                 'mediennr' => '069027182904',
#                 'titel_uw' => '',
#                 'pages' => ''
#               },
#    'orders_projects' => [
#                          
#                           {
#                             'projectoptions' => [
#                                                   {
#                                                     'projectkey_id' => '1',
#                                                     'value' => ''
#                                                   }
#                                                 ],
#                             'project_id' => '1',
#                             'ordersprojects_id' => '2188'
#                           },
#                           {
#                             'ordersprojects_id' => '4658',
#                             'project_id' => '11'
#                           },
#                           {
#                             'project_id' => ''
#                           }
#                         ],
#    'publications' => [
#                        {
#                          'publicationoptions' => [
#                                                    {
#                                                      'value' => '879612',
#                                                      'platformoptionkey_id' => '1'
#                                                    }
#                                                  ],
#                          'publication_id' => '147',
#                          'DELETED' => '1',
#                          'platform_id' => '1'
#                        },
#                        {
#                          'platform_id' => ''
#                        }
#                      ],
#    'scanparameters' => [
#                          {
#                            'format_id' => '2',
#                            'scope' => 'Text',
#                            'scanner_id' => '6',
#                            'scanparameter_id' => '1033',
#                            'resolution_id' => '1'
#                          },
#                          {
#                            'format_id' => '2',
#                            'scanoptions' => [
#                                               {
#                                                 'scanoptionkey_id' => '2',
#                                                 'value_id' => '1'
#                                               }
#                                             ],
#                            'scope' => "Karten, zuerg\x{e4}nzende Textseiten und Einband",
#                            'scanparameter_id' => '1034',
#                            'scanner_id' => '2',
#                            'resolution_id' => '1'
#                          },
#                          {
#                            'format_id' => '',
#                            'scope' => '',
#                            'resolution_id' => '',
#                            'scanner_id' => '5'
#                          }
#                        ],
#    'copyright_id' => "",
#    'status_id' => '9',
#    'documenttype_id' => '1',
#    'control' => 'pen 31.3.07'
#};

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{$config_hash->{'Model::AtacamaDB'}{connect_info}}
);

my $order = $schema_atacama->resultset('Order')->find('ubr02862');
carp "Gefunden: " . $order->modification_date;
$order->save($params);
