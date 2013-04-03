#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin,'..','..','lib');
use Atacama::Schema;
use DBIx::Class::ResultClass::HashRefInflator;
use Data::Dumper;
use Config::ZOMG;
use Getopt::Long;

sub get_schema {
    my $config = Config::ZOMG->new(
        name => 'Atacama',
        path => File::Spec->catfile($FindBin::Bin,'..','..'),
    );
    
    my $config_hash = $config->load;
    my @connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  
    
    my $schema_atacama = Atacama::Schema->connect(
        @{$config_hash->{'Model::AtacamaDB'}{connect_info}}  
    );
    return $schema_atacama;
}

my $order_id = 'ubr00003'; 

GetOptions(
    "order_id=s"    => \$order_id,
);





my $schema = get_schema();
my $rs = $schema->resultset('Order')->search(
    {'me.order_id' => $order_id},
    {
        prefetch =>
            [
                'status',
                'documenttype',
                'copyright',
                'remarks',
                {orders_projects => 'project'},
                {scanparameters => ['scanner','format','resolution']},
                {publications => 'platform'},
                {titel => 'library'},
            ],     
    },    
);
$rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
while (my $hashref = $rs->next) {
    print Dumper($hashref);
}

