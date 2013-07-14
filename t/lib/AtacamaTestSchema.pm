use utf8;
package # hide from PAUSE
    AtacamaTestSchema;
 
use Modern::Perl;
use Atacama::Schema;
use Path::Class;
use Config::General;

my $var_dir         = file(__FILE__)->dir->parent->subdir('var');
my $atacama_db_file = file( $var_dir, 'atacama.db' );
my $sisis_db_file   = file( $var_dir, 'sisis.db' );

my $sqlt_args = {
    producer_args => { sqlite_version => '3.3' },            
    add_drop_table    => 1,
    no_comments       => 1,
    quote_identifiers => 1,
};

my $dbi_attributes = {
    quote_names    => 1,
    sqlite_unicode => 1,
};

sub get_schema {
    my $dsn    = $ENV{"ATACAMA_TEST_SCHEMA_DSN"}
                 || "dbi:SQLite:${atacama_db_file}";
    my $dbuser = $ENV{"ATACAMA_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"ATACAMA_TEST_SCHEMA_DBPASS"} || '';
 
    return Atacama::Schema->connect($dsn, $dbuser, $dbpass, $dbi_attributes);
}
 
sub init_schema {
    my $self = shift;
    my %args = @_;
    
    $ENV{ATACAMA_CONFIG} = $var_dir;
 
    my $schema = $self->get_schema;

    $schema->deploy( $sqlt_args );
 
    $self->populate_schema($schema) if $args{populate};
    
    my $config = {
        name => 'Atacama Test Suite',
        stage => 'testing',
        static_path => '/static/',
        default_view => 'HTML',        
        
        'Model::AtacamaDB' => {
            connect_info => $schema->storage->connect_info,
        },
        setup_components => { except =>  'Atacama::Model::TheSchwartzDB' },
        'Model::SisisDB' => {
            connect_info  => [
                "dbi:SQLite:${sisis_db_file}",
                '',
                '',
                {
                    on_connect_do  => "attach \"${sisis_db_file}\" as sisis",
                    quote_names    => 1,
                    sqlite_unicode =>  0,
                },
            ],
        },
       'Controller::Login' => {
            login_form_args => {
                authenticate_username_field_name => 'username',
                authenticate_password_field_name => 'password',
            },
            action => {
                login => {    
                    Does => ['NoSSL'],
                },
            },
        },   
    };
    my $config_file = file( $var_dir, 'atacama.conf' );
    Config::General::SaveConfig( $config_file, $config );
       
    return $schema;
}

sub populate_schema {
    my $self = shift;
    my $schema = shift;
 
    $schema->storage->dbh->do("PRAGMA synchronous = OFF");
 
    $schema->storage->ensure_connected;
 
    # $schema->create_initial_data;
    $self->create_test_data($schema);
}

sub create_test_data {
 
    my ($self, $schema)=@_;
    my @data;

    #my $data = {
    #};
    
    # $schema->resultset('Order')->create($data);
    
    my $admin = $schema->resultset('User')->create({
        username => 'admin',
        password => 'test',
    });
}    

1;
