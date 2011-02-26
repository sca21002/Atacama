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
        status_id => [ 8, 9, 10 ],          # 8 = fertig z.Veröff, 9 = veröfftl.
                                            # 10 = aus Excel
        'orders_projects.project_id' => 3,  # MedDiss
    },
    {
        join => 'orders_projects',
        page => 100,                          # page to return (defaults to 1)
        rows => 5,                         # number of results per page
    }
);
                                                      
while (my $order = $order_rs->next) {
    my $order_href = {$order->get_columns};
    $order_href->{titel} = $order->titel && {$order->titel->get_columns};
    $order_href->{titel}{titel_isbd} = $order->titel && $order->titel->titel_isbd;
    $order_href->{titel}{library} = $order->titel && $order->titel->library && {$order->titel->library->get_columns};
    foreach my $rel (qw/status documenttype copyright/) {
        $order_href->{$rel} = $order->$rel && {$order->$rel->get_columns};
    }
    foreach my $rel (qw/scanparameters orders_projects publications/) {
        my %options = (
        orders_projects => 'projectoptions',
        scanparameters => 'scanoptions_without_options',
        publications => 'publicationoptions',
        );
        my $rs = $order->$rel;
        while (my $row = $rs->next) {
            my $href = {$row->get_inflated_columns};
            my $option_val = $options{$rel};
            $href->{$option_val} = $row->$option_val if @{$row->$option_val};
            push @{$order_href->{$rel}}, $href;
        }
    }    
    say Dumper($order_href);
}



