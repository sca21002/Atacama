package Atacama::Worker::Job::Sourcefile;
use Moose;
extends 'Atacama::Worker::Job::Base';
use MooseX::Types::Moose qw(Bool Str);
use MooseX::Types::Path::Class qw(File Dir);
use List::Util qw(first);
use Carp;

has 'job' => (
    is => 'rw',
    isa => 'TheSchwartz::Job',
    handles => [qw( arg )],
    required => 1,
);

has '+log_config_basename' => (
    default => 'log4perl_sourcefile.conf',
);

has '+log_basename' => (
    default => 'sourcefile.log',                        
);

has 'scanfile_format' => (
    is => 'rw',
    isa => 'Str',
    builder => '_build_scanfile_format',
    lazy => 1,
);    


has 'format' => (
    is => 'rw',
    isa => 'Str',
);
    


has  'sourcedirs' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [                  
        '/rzblx8_DATA1/digitalisierung/auftraege/',
        '/rzblx8_DATA2/digitalisierung/auftraege/',
        '/rzblx8_DATA3/digitalisierung/auftraege/',
        '/mnt/rzblx9/data/digitalisierung/auftraege/',
    ] },
);

has 'sourcedir' => (
    is => 'rw',
    isa => 'Maybe[Path::Class::Dir]',
    builder => '_build_sourcedir',
    lazy => 1,
);
    
sub  _build_scanfile_format {
    my $self = shift;    
    
    return $self->arg->{scanfile_format} || 'TIFF';
}

sub _build_sourcedir {
    my $self = shift;
    
    carp "order_id: " . $self->order_id;
    carp "source_dirs: " . join('\n', @{$self->sourcedirs}); 
    return first { -d } map { Path::Class::Dir->new( $_, $self->order_id ) }
        @{$self->sourcedirs}
    ;

}

1;
