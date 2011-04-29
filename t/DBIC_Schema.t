#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin,'lib');
use lib File::Spec->catfile($FindBin::Bin,'..','lib');
use_ok( 'AtacamaTestSchema' );
# use_ok('DBIx::Class::ResultClass::HashRefInflator');
use Data::Dumper;

ok( my $schema = AtacamaTestSchema->init_schema(populate => 1), 'created a test schema object' );
ok(my $order = $schema->resultset('Order')->find('ubr02862'),'find ubr02862');
is($order->control,'pen 31.3.07','field control');
my $params = {
              'orders_projects' => [{
                             'projectoptions' => [
                                                   {
                                                     'projectkey_id' => '1',
                                                     'value' => ''
                                                   }
                                                 ],
                             'project_id' => '1',
                             'ordersprojects_id' => '2188'
                           }],
             };

ok($order->save($params),'projectoptions');
is($order->orders_projects->find(2188)->projectvalues->search({})->count,0,
   'Fetch projectvalues');
$params->{orders_projects}[0]{projectoptions}[0]{value} = 'UBR10A003540';
ok($order->save($params),'projectoptions');
is($order->orders_projects->find(2188)->projectvalues->search({})
    ->single->value,'UBR10A003540','Fetch projectvalues');
$params = {
        'scanparameters' => [
                              {
                            'scanoptions' => [{
                                                 'scanoptionkey_id' => '1',
                                                 'value_id' => '1'
                                            }],                                
                                'scanner_id' => '2',
                                'scanparameter_id' => '1034'
                            }]
            };
ok($order->save($params),'scanoptions');
#is($order->scanparameters->find(1034)->scanoptionvalues->single->
#   scanoptionname->name,'Vorlage','Fetch scanoptionvalues');
is($order->scanparameters->find(1034)->scanoptionvalues
   ->single->scanoptionname->name,'ohne Glasplatte','Fetch scanoption');
$params = {
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
                        },
                      ],

          };
ok($order->save($params),'publicationoptions');
ok(my $row = $order->publications->find(147)->platformoptionvalues->single,
    'Fetch row for platformoptionvalue');   
is($row->value,'879612','Fetch publicationvalues');
$params->{publications}[0]{publicationoptions}[0]{value} = '800000';
ok($order->save($params),'update publicationoptionvalue');
is($schema->resultset('Platformoptionvalue')->find({
    platformoptionkey_id => 1, publication_id => '147'})->value,'800000','Fetch updated publicationvalue');
ok($order->save($params),'update publicationoptions');
$params = {
        'publications' => [
                        {
                          'DELETED' => '1',
                          'publication_id' => '147',
                        },
                      ],
          };
is($order->publications->search({publication_id => 147})->count,1,'publication before delete');
ok($order->save($params),'delete publication');
is($order->publications->search({publication_id => 147})->count,0,'publication after delete');
is($order->scanparameters->count,2,'Scanparameter before add a new one');


$params = {
    'scanparameters' => [
                          {
                            'format_id' => '2',
                            'scope' => 'Zusatz',
                            'scanner_id' => '2',
                            'resolution_id' => '1'
                          },
                        ],
};
ok($order->save($params),'add a new scanparameter set');
is($order->scanparameters->count,3,'Scanparameter after add a new one');
$params = {
        'orders_projects' => [
                        {
                          'DELETED' => '1',
                          'ordersprojects_id' => '2188',
                        },
                      ],
          };
is($order->orders_projects->search({ordersprojects_id => '2188'})->count,1,'EOD before delete');
ok($order->save($params),'delete publication');
is($order->orders_projects->search({ordersprojects_id => '2188'})->count,0,'EOD after delete');
$params = {
    'orders_projects' => [
                            {
                             'ordersprojects_id' => '',
                             'project_id' => '1'
           
                            },
                         ],
};
ok($order->save($params),'add a EOD');           
is($order->orders_projects->count,2,'Projekte after add a new one');
done_testing();
