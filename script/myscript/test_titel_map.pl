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

my $titel_new = $schema_atacama->resultset('Titel')->get_new_result_as_href({});

my $signatur = '167/ST 250 P30 D582';

my $buch = $schema_sisis->resultset('D01buch');
my $buch_rs = $buch->search({d01ort => $signatur});
$buch = $buch_rs->first;
my $titel_sisis = $buch->get_titel->[0];
say Dumper($titel_sisis);
%$titel_new = map { $_ => $titel_sisis->{$_} } keys %$titel_new;
say Dumper($titel_new);

# say Dumper($schema_atacama->source('Titel')->column_info('titel_avs')->{sisis});

say $titel_new->map_sisis('mediennr');