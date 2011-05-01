#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use Atacama::Schema;
use Data::Dumper;

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{$config_hash->{'Model::AtacamaDB'}{connect_info}}  
);

my $order_rs = $schema_atacama->resultset('Order')->search(
    {
        order_id => 'ubr00003',
    },
);

my $order = $order_rs->single;

say Dumper($order->orders_projects->get_projects_as_string);
                                                      
