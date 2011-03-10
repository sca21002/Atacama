package Atacama::Helper::TheSchwartz::Scoreboard;

use Moose;
use MooseX::Types::Path::Class;
use Atacama::Helper::TheSchwartz::Scoredata;
use Data::Dumper;


has dir => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    coerce   => 1,
    required => 1,
);

has files => (
    is => 'ro',
    isa => 'ArrayRef[Path::Class::File]',
    lazy_build => 1,
);

has data => (
    is => 'ro',
    isa => 'ArrayRef[Atacama::Helper::TheSchwartz::Scoredata]',
    lazy_build => 1,
);


sub _build_files {
    my $self = shift;
    
    my @files = grep { /scoreboard\.[0-9]+$/ } $self->dir->children;
    return \@files;
}


sub _build_data {
    my $self = shift;
        
    my @data;
    foreach my $file (@{$self->files}) {
        open(SF, '<', $file) or die "Can't open score file '$file': $!\n";
        my %dat = map { chomp; split('=',$_,2) } <SF>;
        close(SF);
        $dat{arg_hashref} = { map { split('=') } split(',', $dat{arg}||'') };
        my $score_data =  Atacama::Helper::TheSchwartz::Scoredata->new(%dat); 
        push @data, $score_data;
    }    
    return \@data;
}
                          
__PACKAGE__->meta->make_immutable;
1; 
