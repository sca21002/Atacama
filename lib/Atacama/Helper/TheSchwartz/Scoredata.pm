package Atacama::Helper::TheSchwartz::Scoredata;

use Moose;

has pid => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has funcname => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has started => (
    is => 'ro',
    isa => 'Int',
    required => 1,
);           

has arg_hashref => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
);

has done => (
    is => 'ro',
    isa => 'Int',
);


has runtime => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);


sub _build_runtime {
    my $self = shift;

    my $secs = ( $self->done || time() ) - $self->started;
    if ($secs < 60) {
        return sprintf("%02d:%02d", 0, $secs);
    } elsif ($secs < 3600) {
        my $min = int($secs/60);
        $secs = $secs%60;
        return sprintf("%02d:%02d", $min, $secs);
    } else {
        my $hr  = int($secs/60/60);
        my $min = int($secs/60%60);
        $secs = $secs%60;
        return sprintf("%d:%02d:%02d", $hr, $min, $secs);
    }   
}

__PACKAGE__->meta->make_immutable;
1; 