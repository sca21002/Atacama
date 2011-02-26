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

my $row = $schema_atacama->resultset('Scanparameter')->new_result({scanner_id => 1});
my $href = { map {$_, $row->$_ || ''} $row->columns };
say Dumper($href);
my $scanner = $row->scanner;
say Dumper({$scanner->get_inflated_columns});
say Dumper($row->scanoptions);
say("2.Teil");
say(Dumper($schema_atacama->resultset('Scanparameter')->get_new_result_as_href({scanner_id => 1})));