#!/usr/bin/perl -w
use strict;
use warnings;
use File::Spec;
use FindBin;
use lib (
    File::Spec->catfile($FindBin::Bin,'..', '..', 'lib'),
    File::Spec->catfile($FindBin::Bin,'..','..','..','Remedi','lib')
        );
use Atacama::Schema;
use feature qw(say);
use Data::Dumper;
use File::Copy;
use File::Path;
# use Remedi::Imagefile;
use File::Slurp;
use Digest::MD5;
use Log::Log4perl qw(:easy);
use Win32 qw(CSIDL_PERSONAL);

my $logfile = File::Spec->catfile(
    Win32::GetFolderPath(CSIDL_PERSONAL), 'save_file_to_extern.log'
);

Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">>$logfile"
    },
    { level    => $TRACE,
      file     => "STDOUT",
    }  
);

my $no_action = 1; 

my $dest_vol1 = 'E:';
my $dest_vol2 = 'F:';

my $hostname = '<host>';
my $database = 'atacama';
my $dsn_source = "DBI:mysql:database=$database;host=$hostname";
my $dsn_target = "DBI:mysql:database=$database";
my $user = 'atacama';
my $password =  '<password>';
my $param = {
    AutoCommit => 1,
    mysql_enable_utf8   => 1,
};

my $schema = Atacama::Schema->connect(
    $dsn_source,
    $user,
    $password,
    $param,
);

my $rs = $schema->resultset('Ocrfile')->search(
    { 
        'orders_projects.project_id' => [55, 56],
        volume         => undef,                   
    },
    {
        join => 'orders_projects', 
    }
);


my $dtf = $schema->storage->datetime_parser;
#my $rs = $schema->resultset('Scanfiles')->search(
#    { 
#        volume         => undef,
#        creation_date  => { '<', '2011-01-01 00:00:00' },
#        'ordersprojects.project_id' => 2,
#    },
#    {
#        join => { ord => 'ordersprojects' }  
#    }
#
#
#);



#my $rs = $schema->resultset('Scanfiles')->search(
#    { 
#        order_id => { 'like' => 'BLO_%' },
#        volume         => undef,                   
#    },
#);


while (my $ocrfile = $rs->next) {
    
    my $ocrfile_name
        = File::Spec->catfile($ocrfile->filepath, $ocrfile->filename);
    $ocrfile_name =~ s#^\\rzblx8_DATA(\d)#\\\\rzblx8\\DATA$1#
        or
    $ocrfile_name =~ s#^\\mnt\\rzblx9#\\\\rzblx9#    
        or    
    die "Ersetzung fehlgeschlagen fuer ${ocrfile_name}!";
    DEBUG("Ocrfile: " . $ocrfile_name);
    my ($volume, $directories, $file) = File::Spec->splitpath($ocrfile_name);
    
    DEBUG('Datei ' . $ocrfile->filename);
  
    # Checksum

    my $md5 = Digest::MD5->new;
    my $bin_data = read_file( $ocrfile_name, binmode => ':raw' ) ;    
    my $md5_digest = $md5->add($bin_data)->hexdigest; 
    DEBUG("MD5-Hash Volume: " . $md5_digest . " Datenbank: " . $ocrfile->md5);
    LOGDIE("Speichern auf $dest_vol1 gescheitert!")
        if $md5_digest ne $ocrfile->md5;

  
    # Speichern auf Speicherort 1
    my $dest_path = File::Spec->catdir($dest_vol1, $directories);
    File::Path::mkpath($dest_path);
    my $dest_file = File::Spec->catfile($dest_path, $file);
    DEBUG("Ziel 1: " . $dest_file);
    copy( $ocrfile_name, $dest_file) or LOGDIE "Copy failed: $!";


    # Speichern auf Speicherort 2
    $dest_path = File::Spec->catdir($dest_vol2, $directories);
    File::Path::mkpath($dest_path);
    $dest_file = File::Spec->catfile($dest_path, $file);
    DEBUG("Ziel 2: " . $dest_file);
    copy( $ocrfile_name, $dest_file) or die "Copy failed: $!";


    #Datenbankeintrag aktualisieren
    $ocrfile->update({
        filepath => $directories,
        volume => 'ext7',
    });
    (my $cnt = unlink $ocrfile_name) 
        ? DEBUG("Datei $ocrfile_name gelöscht")    
        : LOGDIE("Datei $ocrfile_name konnte nicht gelöscht werden!") && die;    
}


