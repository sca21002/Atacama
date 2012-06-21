package Atacama::Worker::Base;
use Moose;
use MooseX::Types::Path::Class qw(Dir File);
use MooseX::Types::Moose qw(HashRef Str);
use Atacama::Types qw(Order_id);
use Config::ZOMG;
use Data::Dumper;
use Log::Log4perl;
use File::Path qw(make_path);

has 'log_file_name' => (
    is      => 'ro',
    isa     => File,
    lazy => 1,
    coerce => 1,
    builder => '_builder_log_file_name',
);

has log => (
    is => 'ro',
    isa => 'Log::Log4perl::Logger',
    builder => '_build_log',
    lazy => 1,
);

has log_basename => (
    is => 'ro',
    isa => Str,
    default => 'worker.log',
);



has log_config_basename => (
    is => 'ro',
    isa => Str,
    default => 'log4perl.conf',
);

has log_config_file => (
    is => 'ro',
    isa => File,
    lazy => 1,
    coerce => 1,
    builder => '_build_log_config_file',
);

has 'log_config_path' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    default => '.',
    coerce   => 1,
);

has 'atacama_config_path' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    default => '.',
    coerce   => 1,
);

has 'atacama_config' => (
    is => 'ro',
    isa => HashRef,
    builder => '_build_atacama_config',
    lazy => 1,
);

has 'job' => (
    is => 'rw',
    isa => 'TheSchwartz::Job',
);

has 'order_id' => (
    is => 'rw',
    isa => Order_id,
);

has 'work_base' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    builder => '_build_work_base',
    coerce => 1,
);                    
                    
                    

has 'work_dir' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    builder => '_build_work_dir',
    coerce => 1,
);

sub _build_atacama_config {
    my $self = shift;
    
    return Config::ZOMG->new(
        name => 'Atacama',
        path => $self->atacama_config_path,
    )->load;
}

sub _build_log {
    my $self = shift;
    
    Log::Log4perl->init($self->log_config_file->stringify);
    return Log::Log4perl->get_logger('Atacama::Worker::Remedi');
}

sub _build_log_config_file {
    my $self = shift;
    
    return Path::Class::File->new(
        $self->log_config_path, $self->log_config_basename
    );
}

sub _builder_log_file_name {
    my $self = shift;
    
    my $log_file_name = Path::Class::File->new(
        $self->work_dir, $self->log_basename
    );
    unlink $log_file_name if -e $log_file_name;
    return $log_file_name;
}

sub _build_work_base {
    my $self = shift;

    return Path::Class::Dir->new(
        $self->atacama_config->{'Atacama::Worker::Remedi'}{work_dir},
    )->absolute;
}    
    

sub _build_work_dir {
    my $self = shift;
    
    my $work_dir = Path::Class::Dir->new( $self->work_base, $self->order_id );
    unless (-d $work_dir) {
        make_path($work_dir->stringify) or die "Coldn't create $work_dir: $!";
    }
    return $work_dir;
}

sub work {
    my $self = shift;
    my $job = shift;
    
    $self->job($job);
    $self->order_id($self->job->arg->{order_id});
    $self->atacama_config_path($self->job->arg->{atacama_config_path});
    $self->log_config_path(
        exists $job->arg->{log_config_path}
        || $job->arg->{atacama_config_path}
    );

   
}

1;