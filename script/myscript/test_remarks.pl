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


my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{$config_hash->{'Model::AtacamaDB'}{connect_info}}
);

my $remark = $schema_atacama->resultset('Remark')->create({order_id => 'ubr02863', login => 'sca21002'});
# print Dumper($remark);
carp "Gefunden: " . $remark->login;

