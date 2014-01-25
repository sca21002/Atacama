use utf8;
package # hide from PAUSE
    SisisTestSchema;
 
use Modern::Perl;
use UBR::Sisis::Schema;
use Path::Class;
use Config::General;

my $var_dir =  file(__FILE__)->dir->parent->subdir('var');
my $db_file = file( $var_dir, 'sisis.db' );

my $sqlt_args = {
    producer_args => { sqlite_version => '3.3' },            
    add_drop_table    => 1,
    add_fk_index      => 0,
    no_comments       => 1,
    quote_identifiers => 1,
};

my $dbi_attributes = {
    quote_names    => 1,
    sqlite_unicode => 0,
    on_connect_do  => "attach \"${db_file}\" as sisis",                      
};

sub get_schema {
    my $dsn    = $ENV{"SISIS_TEST_SCHEMA_DSN"}
                 || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"SISIS_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"SISIS_TEST_SCHEMA_DBPASS"} || '';
 
    return UBR::Sisis::Schema->connect($dsn, $dbuser, $dbpass, $dbi_attributes);
}
 
sub init_schema {
    my $self = shift;
    my %args = @_;
 
    my $schema = $self->get_schema;

    $schema->deploy( $sqlt_args );

    $self->populate_schema($schema) if $args{populate};
    
    my $config = {
        name => 'Sisis Test Suite',
        'Model::SisisDB' => {
            connect_info => $schema->storage->connect_info,
        },
    };
    my $config_file = file( $var_dir, 'sisis.conf' );
    Config::General::SaveConfig( $config_file, $config );    
        
    return $schema;
}

sub populate_schema {
    my $self = shift;
    my $schema = shift;
 
    $schema->storage->dbh->do("PRAGMA synchronous = OFF");
 
    $schema->storage->ensure_connected;
 
    # $schema->create_initial_data;
    #$self->create_test_data($schema);
}

sub create_test_data {
 
    my ($self, $schema)=@_;
    my @data;

    my $data = {
    };
    
#    $schema->resultset('D01buch')->create($data);
    
}    

1;
