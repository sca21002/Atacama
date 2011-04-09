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
    { -and => 
        [
          [ { 'titel_avs' => {like => '%und%'}}, {'titel.zusatz' => {like => '%und%'}}  ],
          [ { 'titel_avs' => {like => '%mit%'}}, {'titel.zusatz' => {like => '%mit%'}}  ],         
         
        #  { 'orders_projects.project_id' => 1 },
          { status_id => 9 },

        ],  
    },
    {
        # join => ['orders_projects', 'titel' ],
        join => [ 'titel' ],
        #page => 100,                          # page to return (defaults to 1)
        #rows => 10,                         # number of results per page
    }
);
                         
say 'Treffer: ',$order_rs->count;

                             
