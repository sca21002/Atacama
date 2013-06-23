#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify; 
use Test::More;

ok(my $schema =  Atacama::Helper::get_schema(
    dir($Bin)->subdir('var'), 'Model::SisisDB', 'UBR::Sisis::Schema', 'sisis',
), 'got a sisis schema');

my @titles;

@titles = $schema->resultset('TitelBuchKey')->get_titles(
    {d01ort => '999/Art.533'}
);

is($titles[0]->{titel_avs}, 'Deutsche Ofenplatten', 'got a title');
is($titles[0]->{bvnr}, 'BV005390971', 'got a BV-nr');

@titles = $schema->resultset('TitelBuchKey')->get_titles(
    {d01ort => '237/TA 6225-2/7' },
);

is(@titles, 6, 'got 6 titles');
is($titles[0]->{autor_avs}, 'Naturhistorischer Verein <Augsburg>',
   'got an author'
);
is($titles[0]->{bvnr}, 'BV000000000', 'got a dummy BV-nr');

done_testing();
