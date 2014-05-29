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
use Remedi::Imagefile;
use Path::Class;
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

my $rs = $schema->resultset('Scanfile')->search(
    { 
        'orders_projects.project_id' => [55, 56],
        volume         => undef,                   
    },
    {
        join => 'orders_projects', 
    }
);


#my $rs = $schema->resultset('Scanfile')->search(
#    { 
#        status_id => [ 9, 10 ],             # 9: veröffentlicht, 10: aus Excel
#        'publications.platform_id' => 1,                # 1: DigiTool
#        'platformoptionvalues.platformoptionkey_id' => 1,
#        'platformoptionvalues.value' => { '!=' , undef },
#        volume         => undef,                   
#    },
#    {
#        join => [ 'ord', { 'publications' => 'platformoptionvalues' } ] 
#    }
#);

#my $rs = $schema->resultset('Scanfile')->search(
#    { 
#        status_id => [ 9, 10 ],             # 9: veröffentlicht, 10: aus Excel
#        'publications.platform_id' => 1,                # 1: DigiTool
#        'platformoptionvalues.platformoptionkey_id' => 1,
#        'platformoptionvalues.value' => { '!=' , undef },
#        volume         => undef,                   
#    },
#    {
#        join => [ 'ord', { 'publications' => 'platformoptionvalues' } ] 
#    }
#);



my $dtf = $schema->storage->datetime_parser;
#my $rs = $schema->resultset('Scanfile')->search(
#    { 
#        volume         => undef,
#        # creation_date  => { '<', '2013-01-01 00:00:00' },
#        'orders_projects.project_id' => 2,
#        status_id => [ 9 ],
#    },
#    {
#        join => { ord => 'orders_projects' }  
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


while (my $scanfile = $rs->next) {
    
    my $scanfile_name
        = File::Spec->catfile($scanfile->filepath, $scanfile->filename);
    $scanfile_name =~ s#^\\rzblx8_DATA(\d)#\\\\rzblx8\\DATA$1#
        or
    $scanfile_name =~ s#^\\mnt\\rzblx9#\\\\rzblx9#    
        or    
    die "Ersetzung fehlgeschlagen fuer ${scanfile_name}!";
    DEBUG("Scanfile: " . $scanfile_name);
    my ($volume, $directories, $file) = File::Spec->splitpath($scanfile_name);
    
    DEBUG('Datei ' . $scanfile->filename);
    # Speichern auf Speicherort 1
    my $dest_path = File::Spec->catdir($dest_vol1, $directories);
    File::Path::mkpath($dest_path);
    my $dest_file = File::Spec->catfile($dest_path, $file);
    DEBUG("Ziel 1: " . $dest_file);
    copy( $scanfile_name, $dest_file) or die "Copy failed: $!"
        unless $no_action;
    my ($image, $md5);
    eval {
        $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => qr/ubr\d{5}/,
            file => Path::Class::File->new($dest_file)->stringify,
        );
    };
    if ($@) {
        DEBUG("Konnte MD5-Hash nicht berechnen für " . $dest_file . " Fehler: $@");
    } else {
        $md5 = $image->md5_checksum;
        DEBUG("MD5-Hash Volume 1: " . $md5 .
              " Datenbank: " . $scanfile->md5);
        LOGDIE("Speichern auf $dest_vol2 gescheitert!")
            if $md5 ne $scanfile->md5;
    }
    # Speichern auf Speicherort 2
    $dest_path = File::Spec->catdir($dest_vol2, $directories);
    File::Path::mkpath($dest_path);
    $dest_file = File::Spec->catfile($dest_path, $file);
    DEBUG("Ziel 2: " . $dest_file);
    copy( $scanfile_name, $dest_file) or die "Copy failed: $!"
        unless $no_action;
    eval {
        $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => qr/ubr\d{5}/,
            file => Path::Class::File->new($dest_file)->stringify,
        );
    };    
    if ($@) {
        DEBUG("Konnte Imagedatei " . $dest_file . " nicht initialisieren.");
    } else {
        eval {
            $md5 = $image->md5_checksum;
        };
        if ($@) {
            DEBUG("Konnte MD5-Hash nicht berechnen für " . $dest_file . "Fehler: $@");
        }
        DEBUG("MD5-Hash Volume 2: " . $md5 .
              " Datenbank: " . $scanfile->md5);
        LOGDIE("Speichern auf $dest_vol2 gescheitert: MD5 ungleich " . $md5 .
            " <> " . $scanfile->md5)
                if $md5 ne $scanfile->md5;
    }
    unless ($no_action) {
        $scanfile->update({
            filepath => $directories,
            volume => 'ext7',
        });
        #(my $cnt = unlink $scanfile_name) 
        #? DEBUG("Datei $scanfile_name gelöscht")    
        #: LOGDIE("Datei $scanfile_name konnte nicht gelöscht werden!") && die;
    }
}


