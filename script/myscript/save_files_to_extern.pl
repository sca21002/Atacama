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
use Try::Tiny;
use Win32 qw(CSIDL_PERSONAL);

my $logfile = path( 
    Win32::GetFolderPath(CSIDL_PERSONAL), 
    'save_file_to_extern.log'
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

#my $rs = $schema->resultset('Scanfile')->search(
#    {
#        status_id => [ 20 ],                # 9: veröffentlicht, 10: aus Excel
#                                            # 20: wird nicht veröffentlicht
#        volume         => undef,                   
#    },
#    {
#        join => [ 'ord' ], 
#    }
#);

#warn $schema->resultset('Scanfile')->search({
#    status_id => [ 9, 10 ],                                              
#
#
#})->count;

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
#        order_id => 'ubr15938',
#        volume   => undef,
#     },
#
#);


#my $dtf = $schema->storage->datetime_parser;
#my $rs = $schema->resultset('Scanfile')->search(
#    { 
#        volume         => undef,
#        # creation_date  => { '<', '2013-01-01 00:00:00' },
#        'orders_projects.project_id' => 67,
#        status_id => [ 9,19 ],
#    },
#    {
#        join => { ord => 'orders_projects' }  
#    }
#
#
#);

my $rs = $schema->resultset('Scanfile')->search(
    { 
        order_id => 'ubr11970',
        volume         => undef,                   
    },
);


#my $rs = $schema->resultset('Scanfile')->search(
#    { 
#        order_id => { 'like' => 'BLO_%' },
#        volume         => undef,                   
#    },
#);


while (my $scanfile = $rs->next) {
    
    my $scanfile_name
        = path($scanfile->filepath, $scanfile->filename);
    $scanfile_name =~ s#^\\rzblx8_DATA(\d)#\\\\rzblx8\\DATA$1#
        or
    $scanfile_name =~ s#^\\mnt\\rzblx9#\\\\rzblx9#    
        or
    $scanfile_name =~ s#^\\mnt\\rzblx10b#\\\\rzblx10b#
        or
    die "Ersetzung fehlgeschlagen fuer ${scanfile_name}!";
    DEBUG("Scanfile: " . $scanfile_name);
    my ($volume, $directories, $file) = File::Spec->splitpath($scanfile_name);
    
    DEBUG('Datei ' . $scanfile->filename);
    # Speichern auf Speicherort 1
    my $dest_path = path($dest_vol1, $directories);
    $dest_path->mkpath;
    my $dest_file = path($dest_path, $file);
    DEBUG("Ziel 1: " . $dest_file);
    path($scanfile_name)->copy($dest_file) or die "Copy failed: $!"
        unless $no_action;
    my ($image, $md5);
    try {
        $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => qr/ubr\d{5}/,
            file => Path::Class::File->new($dest_file)->stringify,
        );
        $md5 = $image->md5_checksum;
    } catch {
        DEBUG("Konnte MD5-Hash nicht berechnen für '$dest_file'. Fehler: $_");
    }; 
    DEBUG("MD5-Hash Volume 1: '$md5' Datenbank: " . $scanfile->md5);
    LOGDIE("Speichern auf $dest_vol2 gescheitert!")
        if $md5 ne $scanfile->md5;
 
    # Speichern auf Speicherort 2
    $dest_path = File::Spec->catdir($dest_vol2, $directories);
    File::Path::mkpath($dest_path);
    $dest_file = File::Spec->catfile($dest_path, $file);
    DEBUG("Ziel 2: " . $dest_file);
    copy( $scanfile_name, $dest_file) or die "Copy failed: $!"
        unless $no_action;
    try {
        $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => qr/ubr\d{5}/,
            file => Path::Class::File->new($dest_file)->stringify,
        );
        $md5 = $image->md5_checksum;
    } catch {
        DEBUG("Konnte MD5-Hash nicht berechnen für '$dest_file'. Fehler: $_");
        DEBUG("MD5-Hash Volume 2: '$md5'Datenbank: " . $scanfile->md5);
        LOGDIE("Speichern auf '$dest_vol2' gescheitert: MD5 ungleich '$md5' <> "
            . $scanfile->md5)
                if $md5 ne $scanfile->md5;
    };
    unless ($no_action) {
        $scanfile->update({
            filepath => $directories,
            volume => 'ext10',
        });
        (my $cnt = unlink $scanfile_name) 
        ? DEBUG("Datei '$scanfile_name' gelöscht")    
        : LOGDIE("Datei '$scanfile_name' konnte nicht gelöscht werden!");
    }
}
