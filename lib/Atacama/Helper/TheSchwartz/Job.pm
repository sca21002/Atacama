use utf8;
package Atacama::Helper::TheSchwartz::Job;

use Moose;
use Atacama::Types qw(Bool DateTime File HashRef Str);
use namespace::autoclean;

has 'pid' => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has 'funcname' => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has 'started' => (
    is => 'ro',
    isa => DateTime,
    required => 1,
    coerce => 1,
);           

has 'arg' => (
    is => 'ro',
    isa => Str,
    predicate => 'has_arg',
);

has 'arg_hashref' => (
    is => 'rw',
    isa => HashRef,
    lazy_build => 1,
);

has 'done' => (
    is => 'ro',
    isa => DateTime,
    coerce => 1,
);


has 'runtime' => (
    is => 'ro',
    isa => Str,
    lazy_build => 1,
);

has 'remedi_configfile' => (
    is => 'ro',
    isa => File,
    coerce => 1,
    lazy_build => 1, 
);

has 'does_digifooter' => (
    is => 'ro',
    isa => Bool,
    lazy_build => 1, 
);

has 'does_copy_files' => (
    is => 'ro',
    isa => Bool,
    lazy_build => 1, 
);

has 'does_csv' => (
    is => 'ro',
    isa => Bool,
    lazy_build => 1, 
);

has 'does_mets' => (
    is => 'ro',
    isa => Bool,
    lazy_build => 1, 
);


has 'source_format' => (
    is => 'ro',
    isa => Str,
    lazy_build => 1, 
);

has 'order_id' => (
    is => 'ro',
    isa => Str,
    lazy_build => 1, 
);

has 'source_pdf_file' => (
    is => 'ro',
    isa => Str,
    lazy_build => 1, 
);

has 'additional_args' => (
    is => 'ro',
    isa => Str,
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
    my $arg_hashref = { map { split('=',$_,2) } split(',', $self->arg ||'') };
    return $arg_hashref;
}

sub _build_remedi_configfile {
    (shift)->arg_hashref->{remedi_configfile} || '';    
}

sub _build_does_digifooter {
    (shift)->arg_hashref->{does_digifooter} || '';    
}

sub _build_does_copy_files {
    (shift)->arg_hashref->{does_copy_files} || '';    
}

sub _build_does_csv {
    (shift)->arg_hashref->{does_csv} || '';    
}

sub _build_does_mets {
    (shift)->arg_hashref->{does_mets} || '';    
}

sub _build_source_format {
    (shift)->arg_hashref->{source_format} || '';    
}

sub _build_order_id {
    (shift)->arg_hashref->{order_id} || '';    
}

sub _build_source_pdf_file {
    (shift)->arg_hashref->{source_pdf_file} || '';    
}

sub _build_additional_args {
    my $self = shift;
    
    my %arg_hashref = %{$self->arg_hashref};
    my @standard_keys = qw(
        remedi_configfile does_digifooter does_copy_files does_csv source_format
        order_id does_mets source_pdf_file
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
