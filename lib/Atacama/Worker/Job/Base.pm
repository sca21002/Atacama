package Atacama::Worker::Job::Base;
use Moose;
use MooseX::NonMoose;
extends 'TheSchwartz::Job';
use Atacama::Types qw(Order_id);
use MooseX::Types::Path::Class qw(File Dir);
use MooseX::Types::Moose qw(HashRef Str);
use Atacama::Schema;
use Config::ZOMG;
use Log::Log4perl;
use File::Path qw(make_path);


has 'job' => (
    is => 'rw',
    isa => 'TheSchwartz::Job',
    handles => [qw( arg completed)],
    required => 1,
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

has 'atacama_schema' => (
    is => 'ro',
    isa => 'Atacama::Schema',
    builder => '_build_atacama_schema',
    lazy => 1,
);

has 'log_dir' => (
    is => 'ro',
    isa => Dir,
    lazy => 1,
    coerce => 1,
    builder => '_build_log_dir',
);

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

has 'order' => (
    is => 'ro',
    isa => 'Atacama::Schema::Result::Order',
    builder => '_build_order',
    lazy => 1,
);

has 'order_id' => (
    is => 'rw',
    isa => Order_id,
    builder => '_build_order_id',
    lazy => 1,
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

sub _build_order_id {
    my $self = shift;
    
    return exists $self->arg->{order_id} && $self->arg->{order_id};
}

sub _build_order {
    my $self = shift;
    
    my $order = $self->atacama_schema->resultset('Order')->find($self->order_id)
        or croak("Kein Auftrag zu " . $self->order_id . " gefunden!");    
}

sub _build_atacama_schema {
    my $self = shift;

    my @dbic_connect_info
        = @{ $self->atacama_config->{'Model::AtacamaDB'}{connect_info} };
    my $atacama_schema = Atacama::Schema->connect(@dbic_connect_info)
        or $self->log->logcroak("Datenbankverbindung gescheitert");
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
    
    my $log_dir = $self->log_dir;
    unless (-d $log_dir) {
        make_path($log_dir->stringify, {error => \my $err} );
        if (@$err) {
            for my $diag (@$err) {
                my ($dir, $message) = %$diag;
                if ($dir eq '') {
                    print "general error: $message\n";
                }
                else {
                    print "problem making $dir: $message\n";
                }
            }    
        }
    }
    my $log_file_name = Path::Class::File->new(
        $self->log_dir  , $self->log_basename
    );
    unlink $log_file_name if -e $log_file_name;
    return $log_file_name;
}

sub _build_log_config_file {
    my $self = shift;
    
    return Path::Class::File->new(
        $self->log_config_path, $self->log_config_basename
    );
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

1;
