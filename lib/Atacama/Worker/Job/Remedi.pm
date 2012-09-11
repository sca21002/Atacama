package Atacama::Worker::Job::Remedi;
use Moose;
extends 'Atacama::Worker::Job::Base';
use MooseX::Types::Moose qw(Bool Str);
use MooseX::Types::Path::Class qw(File Dir);


has 'job' => (
    is => 'rw',
    isa => 'TheSchwartz::Job',
    handles => [qw( arg )],
    required => 1,
);

has 'csv_basename' => (
    is => 'ro',
    isa => Str,
    builder => '_build_csv_basename',
    lazy => 1,
);

has 'csv_file' => (
    is => 'ro',
    isa => File,
    builder => '_build_csv_file',
    lazy => 1,
);

has 'csv_save_dir' => (
    is => 'ro',
    isa => Dir,
    builder => '_build_csv_save_dir',
    lazy => 1,
);

has 'does_copy_files' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_copy_files',
    lazy => 1,
);

has 'does_csv' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_csv',
    lazy => 1,
);

has 'does_digifooter' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_digifooter',
    lazy => 1,
);

has 'does_mets' => (
    is => 'ro',
    isa => Bool,
    builder => '_build_does_mets',
    lazy => 1,
);

sub _build_csv_basename {
    my $self = shift;
    
    return $self->order_id . '.csv';
}

sub _build_csv_file {
    my $self = shift;
    
    return Path::Class::File->new($self->work_dir, $self->csv_basename);
}

sub _build_csv_save_dir {
    my $self = shift;
    
    my $csv_save_dir = Path::Class::Dir->new($self->work_base, 'csv_save');
    unless (-d $csv_save_dir) {
        File::Path::make_path($csv_save_dir->stringify)
            or die "Coldn't create $csv_save_dir: $!";
    }
    return $csv_save_dir;
}


sub _build_does_copy_files {
    my $self = shift;
    
    return exists $self->arg->{copy_files} && $self->arg->{copy_files};
}

sub _build_does_csv {
    my $self = shift;
    
    return exists $self->arg->{csv} && $self->arg->{csv};    
}

sub _build_does_digifooter {
    my $self = shift;
    
    return exists $self->arg->{digifooter} && $self->job_arg->{digifooter};    
}

sub _build_does_mets {
    my $self = shift;
    
    return exists $self->arg->{mets} && $self->arg->{mets};    
}

1;
