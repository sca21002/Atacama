package Atacama::Helper::TheSchwartz::Job;

use Moose;
use MooseX::Types::DateTime;
use MooseX::Types::Path::Class;

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
    isa => 'DateTime',
    required => 1,
    coerce => 1,
);           

has arg => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_arg',
);

has arg_hashref => (
    is => 'rw',
    isa => 'HashRef',
    lazy_build => 1,
);

has done => (
    is => 'ro',
    isa => 'DateTime',
    coerce => 1,
);


has runtime => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

has configfile => (
    is => 'ro',
    isa => 'Path::Class::File',
    coerce => 1,
    lazy_build => 1, 
);

has digifooter => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1, 
);

has copy_files => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1, 
);

has csv => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1, 
);

has mets => (
    is => 'ro',
    isa => 'Bool',
    lazy_build => 1, 
);


has source_format => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1, 
);

has order_id => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1, 
);

has source_pdf_name => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1, 
);

has additional_args => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_runtime {
    my $self = shift;

    my $runtime = ( $self->done || DateTime->now ) - $self->started;
    return sprintf(
        "%d:%02d:%02d", $runtime->in_units('hours', 'minutes', 'seconds')
    );
}

sub _build_arg_hashref {
    my $self = shift;
    
    return unless $self->has_arg;
    my $arg_hashref = { map { split('=') } split(',', $self->arg ||'') };
    return $arg_hashref;
}

sub _build_configfile {
    (shift)->arg_hashref->{configfile} || '';    
}

sub _build_digifooter {
    (shift)->arg_hashref->{digifooter} || '';    
}

sub _build_copy_files {
    (shift)->arg_hashref->{copy_files} || '';    
}

sub _build_csv {
    (shift)->arg_hashref->{csv} || '';    
}

sub _build_mets {
    (shift)->arg_hashref->{mets} || '';    
}

sub _build_source_format {
    (shift)->arg_hashref->{source_format} || '';    
}

sub _build_order_id {
    (shift)->arg_hashref->{order_id} || '';    
}

sub _build_source_pdf_name {
    (shift)->arg_hashref->{source_pdf_name} || '';    
}

sub _build_additional_args {
    my $self = shift;
    
    my %arg_hashref = %{$self->arg_hashref};
    my @standard_keys = qw(
        configfile digifooter copy_files csv source_format order_id mets
        source_pdf_name
    );
    my %standard_hash;
    undef @standard_hash{ @standard_keys };                      # hash-slice 
    my @additional_keys
        = grep { !exists( $standard_hash{$_} ) } keys %arg_hashref;
    my @rest =  map { $_ . '=' . $arg_hashref{$_} } @additional_keys;
    return join(',', @rest);
}

__PACKAGE__->meta->make_immutable;
1; 
