#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use Atacama::Schema;
use Data::Dumper;
use Path::Class;

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my $dir = Path::Class::Dir->new($config_hash->{'Controller::Remedi'}{remedi_configdir});

my @list = grep { $_->basename =~ /^remedi_de-.*\.yml$/ } $dir->children;
foreach my $file (@list) {
    say $file;
}


