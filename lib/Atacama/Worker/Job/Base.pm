package Atacama::Worker::Job::Base;
use Moose;
use Atacama::Types qw(Dir File HashRef Order_id Path Str);
use Path::Tiny;
use Atacama::Schema;
use Config::ZOMG;
use Log::Log4perl;
use MooseX::ClassAttribute;
use namespace::autoclean;
use Carp qw(croak);
use Data::Dumper;

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

has 'atacama_schema' => (
    is => 'ro',
    isa => 'Atacama::Schema',
    builder => '_build_atacama_schema',
    lazy => 1,
);

class_has 'log_dir' => (
    is => 'ro',
    isa => Dir,
    lazy => 1,
    coerce => 1,
    builder => '_build_log_dir',
);

class_has 'log_file_name' => (
    is      => 'ro',
    isa     => Path,
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

class_has log_basename => (
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

has 'order' => (
    is => 'ro',
    isa => 'Atacama::Schema::Result::Order',
    builder => '_build_order',
    lazy => 1,
);

has 'order_id' => (
    is => 'rw',
    isa => Order_id,
    required => 1,
);

has 'working_base' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    builder => '_build_working_base',
    coerce => 1,
);                    


has 'working_dir' => (
    is => 'rw',
    isa => Dir,
    lazy => 1,
    builder => '_build_working_dir',
    coerce => 1,
);


sub _build_atacama_config {
    my $self = shift;
    
    my $atacama_config = Config::ZOMG->new(
        name => 'atacama',
        path => $self->atacama_config_path,
    )->load;
    $self->log->logdie(
        "No configuration file found in '" . $self->atacama_config_path . "'!"
    ) unless %$atacama_config;
    return $atacama_config;
}

sub _build_order {
    my $self = shift;
    
    my $order = $self->atacama_schema->resultset('Order')->find($self->order_id)
        or croak("No order found for '" . $self->order_id . "'!");    
}

sub _build_atacama_schema {
    my $self = shift;

    my @dbic_connect_info
        = @{ $self->atacama_config->{'Model::AtacamaDB'}{connect_info} };
    my $atacama_schema = Atacama::Schema->connect(@dbic_connect_info);
    $atacama_schema->storage->ensure_connected;
    return $atacama_schema;
}

sub _build_log {
    my $self = shift;
   
    Log::Log4perl->init($self->log_config_file->stringify);
    return Log::Log4perl->get_logger('Atacama::Worker::Remedi');
}

sub _build_log_dir { '.' }

sub _builder_log_file_name {
    my $self = shift;
    
    $self->log_dir->mkpath;                  # no op if log_dir doesn't exist
    my $log_file_name = path( $self->log_dir, $self->log_basename );
    $log_file_name->remove;                     # no op if file doesn't exist
    return $log_file_name;
}

sub _build_log_config_file {
    my $self = shift;
    
    return path( $self->log_config_path, $self->log_config_basename );
}

sub _build_working_base {
    my $self = shift;

    my $working_base = path(
        $self->atacama_config->{'Atacama::Worker::Remedi'}{working_base},
    );
    $self->log->logdie("working_base '$working_base' doesn't exist")
        unless $working_base->is_dir;
    return $working_base->absolute;
}    
    
sub _build_working_dir {
    my $self = shift;
    
    my $working_dir = path( $self->working_base, $self->order_id );
    $working_dir->mkpath({error => \my $err});
    $self->log->logdie(
        "Couldn't create working directory: $working_dir " . Dumper($err)
    ) if @$err; 
    return $working_dir;
}


__PACKAGE__->meta->make_immutable;
1;
