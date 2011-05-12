#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use UBR::Sisis::Schema;
use Atacama::Schema;
use Data::Dumper;
use Carp;

binmode(STDOUT, ":utf8");

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::SisisDB'}{connect_info}};  

say Dumper(@connect);
my $storage_type = $config_hash->{'Model::SisisDB'}{storage_type};
say Dumper($storage_type);

UBR::Sisis::Schema->storage_type($storage_type);
my $schema_sisis = UBR::Sisis::Schema->connect(
    @{$config_hash->{'Model::SisisDB'}{connect_info}}  
);

@connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{ $config_hash->{'Model::AtacamaDB'}{connect_info} }  
);


# my $bvnr = 'BV005390971';
my $bvnr = 'BV014294377';

my $titel_verbund_rs 
    = $schema_sisis
        ->resultset('TitelVerbund')->search({verbundid => $bvnr },
);

say "Treffer ($bvnr): ", $titel_verbund_rs->count;
say Dumper($titel_verbund_rs->first->get_titel);
