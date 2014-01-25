package Atacama::Helper::TheSchwartz::Scoreboard;

use Moose;
use Atacama::Types qw(ArrayRef Dir File TheSchwartz_Job);
use aliased 'Atacama::Helper::TheSchwartz::Job';
use Data::Dumper;

has dir => (
    is => 'ro',
    isa => Dir,
    coerce   => 1,
    required => 1,
);

has files => (
    is => 'ro',
    isa => ArrayRef[File],
    lazy_build => 1,
);

has jobs => (
    is => 'ro',
    isa => ArrayRef[TheSchwartz_Job],
    lazy_build => 1,
);


sub _build_files {
    my $self = shift;
    
    my @files = grep { /scoreboard\.[0-9]+$/ } $self->dir->children;
    return \@files;
}


sub _build_jobs {
    my $self = shift;
        
    my @jobs;
    foreach my $file (@{$self->files}) {
        open(SF, '<', $file) or die "Can't open score file '$file': $!\n";
        my %dat = map { chomp; split('=', $_, 2) } <SF>;
        close(SF);
        my $job = Job->new(%dat); 
        push @jobs, $job;
    }    
    return \@jobs;
}
                          
__PACKAGE__->meta->make_immutable;
1; 
