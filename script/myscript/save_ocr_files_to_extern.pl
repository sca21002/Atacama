#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use FindBin qw($Bin);
use Path::Tiny;
use lib (
    path($Bin)->parent(2)->child('lib')->stringify,
    path($Bin)->parent(3)->child(qw(Remedi lib))->stringify,
);
use Atacama::Helper;
use Atacama::Schema;
use Data::Dumper;
#use File::Copy;
#use File::Path;
use Remedi::Imagefile;
use Log::Log4perl qw(:easy);
use Digest::MD5;
use Try::Tiny;
use Win32 qw(CSIDL_PERSONAL);

my $logfile = path( 
    Win32::GetFolderPath(CSIDL_PERSONAL), 
    'save_ocr_file_to_extern.log'
);

Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">>$logfile"
    },
    { level    => $TRACE,
      file     => "STDOUT",
    }  
);

my $no_action = 0; 

my $dest_vol1 = 'E:';
my $dest_vol2 = 'F:';

my $schema = Atacama::Helper::get_schema( path($Bin)->parent(2) );


my $rs = $schema->resultset('Ocrfile')->search(
    { 
        status_id => [ 9, 10 ],             # 9: veröffentlicht, 10: aus Excel
        'publications.platform_id' => 1,                # 1: DigiTool
        'platformoptionvalues.platformoptionkey_id' => 1,
        'platformoptionvalues.value' => { '!=' , undef },
        volume         => undef,                   
    },
    {
        join => [ 'ord', { 'publications' => 'platformoptionvalues' } ] 
    }
);

#my $rs = $schema->resultset('Ocrfile')->search(
#    { 
#        'orders_projects.project_id' => [55, 56],
#        volume         => undef,                   
#    },
#    {
#        join => 'orders_projects', 
#    }
#);


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
    
    DEBUG('Datei ' . $ocrfile->filename);
  
    my $ocrfile_name
        = path($ocrfile->filepath, $ocrfile->filename);
    $ocrfile_name =~ s#^\\rzblx8_DATA(\d)#\\\\rzblx8\\DATA$1#
        or
    $ocrfile_name =~ s#^\\mnt\\rzblx9#\\\\rzblx9#    
        or
    $ocrfile_name =~ s#^\\mnt\\rzblx10b#\\\\rzblx10b#
        or
    die "Ersetzung fehlgeschlagen fuer ${ocrfile_name}!";
    DEBUG("OCRfile: " . $ocrfile_name);
    my ($volume, $directories, $file) = File::Spec->splitpath($scanfile_name);

    # Checksum
    my $md5 = Digest::MD5->new;
    my $bin_data = read_file( $ocrfile_name, binmode => ':raw' ) ;    
    my $md5_digest = $md5->add($bin_data)->hexdigest; 
    DEBUG("MD5-Hash Volume: " . $md5_digest . " Datenbank: " . $ocrfile->md5);
    LOGDIE("Speichern auf $dest_vol1 gescheitert!")
        if $md5_digest ne $ocrfile->md5;

  
    # Speichern auf Speicherort 1
    my $dest_path = path($dest_vol1, $directories);
    $dest_path->mkpath;
    my $dest_file = path($dest_path, $file);
    DEBUG("Ziel 1: " . $dest_file);
    path($ocrfile_name)->copy($dest_file) or die "Copy failed: $!"
        unless $no_action;


    # Speichern auf Speicherort 2
    $dest_path = path($dest_vol2, $directories);
    $dest_path->mkpath;
    $dest_file = path($dest_path, $file);
    DEBUG("Ziel 2: " . $dest_file);
    path($ocrfile_name)->copy($dest_file) or die "Copy failed: $!"

    #Datenbankeintrag aktualisieren
    $ocrfile->update({
        filepath => $directories,
        volume => 'ext9',
    });
    (my $cnt = unlink $ocrfile_name) 
        ? DEBUG("Datei $ocrfile_name gelöscht")    
        : LOGDIE("Datei $ocrfile_name konnte nicht gelöscht werden!") && die;    
}

