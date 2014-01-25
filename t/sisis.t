#!/usr/bin/env perl
use Modern::Perl;
use utf8;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir('lib')->stringify; 
use Test::More;
use Atacama::Helper;
use SisisTestSchema;
#use Data::Dumper;

#$ENV{DBIC_TRACE} = 1;

ok( my $sisis_schema = SisisTestSchema->init_schema(populate => 1),
    'created a sisis test schema object' );

my $data;
$data = {
    katkey => 979288,
    mcopyno => 979288,
    seqnr => 1,        
};
$sisis_schema->resultset('TitelBuchKey')->create($data);
$data = {
        d01gsi => 'TEMP1446895',
        d01ex  => ' ',
        d01zweig => 3,
        d01ort => '999/Art.533',
        d01mcopyno => 979288,
        d01titlecatkey => 979288,
        d01usedcatkey => 979288,                
};
$sisis_schema->resultset('D01buch')->create($data);        
$data = {
    katkey => 979288,
    autor_avs => 'Schröder, Albert',
    titel_avs => 'Deutsche Ofenplatten',
    verlagsort => 'Leipzig',
    verlag => 'Bibliogr. Inst.',
    erschjahr => '1936',         
};
$sisis_schema->resultset('TitelDupdaten')->create($data);
$data = {
    katkey => 979288,
    verbundid => 'BV005390971',
};
$sisis_schema->resultset('TitelVerbund')->create($data);

$data = {
        d01gsi => '069035395077',
        d01ex  => ' ',
        d01zweig => 0,
        d01ort => '237/TA 6225-2/7',
        d01mcopyno => 2536481,
        d01titlecatkey => 2536481,
        d01usedcatkey => 2536481,     
};
$sisis_schema->resultset('D01buch')->create($data);
my $data_aref;
$data_aref = [
    [ 2536481, 2536481, 1 ],
    [ 2536482, 2536481, 2 ],
    [ 2536483, 2536481, 3 ],
    [ 2536484, 2536481, 4 ],
    [ 2536486, 2536481, 5 ],
    [ 2536485, 2536481, 6 ],
];
foreach my $el (@$data_aref) {
    undef $data;
    @$data{qw(katkey mcopyno seqnr)} = @$el;
    $sisis_schema->resultset('TitelBuchKey')->create($data);
}
$data_aref = [
    [ 2536481, 'Naturhistorischer Verein <Augsburg>' ],
    [ 2536482, 'Naturhistorischer Verein <Augsburg>' ],
    [ 2536483, 'Naturhistorischer Verein <Augsburg>' ],
    [ 2536484, 'Naturhistorischer Verein <Augsburg>' ],
    [ 2536486, 'Naturhistorischer Verein <Augsburg>' ],
    [ 2536485, 'Naturhistorischer Verein <Augsburg>' ],
];
foreach my $el (@$data_aref) {
    undef $data;
    @$data{qw(katkey autor_avs)} = @$el;
    $sisis_schema->resultset('TitelDupdaten')->create($data);
}
my @titles;

@titles = $sisis_schema->resultset('TitelBuchKey')->get_titles(
    {d01ort => '999/Art.533'}
);

is($titles[0]->{titel_avs}, 'Deutsche Ofenplatten', 'got a title');
is($titles[0]->{bvnr}, 'BV005390971', 'got a BV-nr');

@titles = $sisis_schema->resultset('TitelBuchKey')->get_titles(
    {d01ort => '237/TA 6225-2/7' },
);

is(@titles, 6, 'got 6 titles');
is($titles[0]->{autor_avs}, 'Naturhistorischer Verein <Augsburg>',
   'got an author'
);
is($titles[0]->{bvnr}, 'BV000000000', 'got a dummy BV-nr');

done_testing();
