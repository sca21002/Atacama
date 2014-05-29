#!/usr/bin/perl -w
use strict;
use warnings;
use File::Spec;
use FindBin;
use lib (
    File::Spec->catfile($FindBin::Bin,'..','..','lib'),
        );
use Atacama::Schema;
use feature qw(say);
use Log::Log4perl qw(:easy);
use Win32 qw(CSIDL_PERSONAL);
use IO::All;
use Path::Class;
use Data::Dumper;

$| = 1;

my $logfile = File::Spec->catfile(
    Win32::GetFolderPath(CSIDL_PERSONAL), 'check_dirs_for_delete.log'
);

Log::Log4perl->easy_init(
    { level   => $INFO,
      file    => ">$logfile"
    },
    { level    => $INFO,
      file     => "STDOUT",
    }  
);

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


my $dir = Path::Class::Dir->new('\\\\rzblx8\DATA2\digitalisierung\auftraege');
#my $dir = Path::Class::Dir->new('\\\\rzblx8\DATA3\digitalisierung\auftraege');
my $geloescht = 0;

$dir->recurse(
        callback => \&list_files,
        depthfirst => 1,
        preorder => 0,    
);
INFO("Es wurden " . sprintf("%.1f", $geloescht /1024 /1024) . " MB gelöscht");



sub list_files {
    my $entry = shift;
    if ($entry->is_dir) {
        TRACE("Verzeichnis " . $entry . " wird geprueft");
        my $order_id = $entry->dir_list(-1);
        if ($order_id =~ /^ubr\d{5}/) {
            TRACE("order_id: " . $order_id);
            my $rs = $schema->resultset('Scanfile')->search(
                {
                    order_id =>  $order_id,
                },
                {
                    columns => [ qw/volume/ ],
                    distinct => 1
                }
            );
            my @rows = $rs->all;
            if (@rows) {
                if (scalar @rows == 1) {
                    if ( $rows[0]->volume && $rows[0]->volume =~ /^ext/i ) { 
                        TRACE("Volume: " . $rows[0]->volume);
                        check_dir($entry, $order_id);  
                    } else {
                        if ($rows[0]->volume) {
                            WARN('Unbekanntes Volume: ' . $rows[0]->volume);
                        } else { 
                            TRACE("Volume ist NULL");
                        }
                    }    
                } else {
                    WARN("Mehr als ein Volume angegeben fuer die Scandateien");    
                }
            }
        }
        unless ($entry->children) {
            TRACE("Verzeichnis " . $entry . " ist leer und wird gelöscht.");
            if ( rmdir $entry->stringify) {
                INFO( $entry . " wurde geloescht");    
            }
            else {
                WARN("Loeschen von " . $entry . " fehlgeschlagen: $!");    
            }
        }
    }
}

sub check_dir {
    my $dir = shift;
    my $order_id = shift;
   
    my @list = $dir->children;
   
    foreach my $entry (@list) {
        if ($entry->is_dir) {
            if ($entry->children) { check_dir($entry, $order_id); }
            unless ( $entry->children ) { 
                TRACE($entry . " ist ein leeres Verzeichnis und wird gelöscht.");
                if ( rmdir $entry->stringify) {
                    INFO( $entry . " wurde geloescht");    
                }
                else {
                    WARN("Loeschen von " . $entry . " fehlgeschlagen: $!");    
                }
            } else {
                WARN("Verzeichnis " . $entry . " ist nicht leer und wird daher nicht geloescht!");
            }
        } else {
            my ($suffix) = $entry->basename =~ qr/.*\.([^.]*)$/;
            if ( $suffix && $suffix =~ /pdf|OIP|job|jo_|OJP|TMP|tmp/
                 or $entry->basename eq 'Thumbs.db'
                 or $entry->basename =~ /^setupRight/
                 or $suffix && $order_id
                    && $entry->basename =~ /^$order_id/
                    && $suffix =~ /tif|tiff|jpg|txt|doc/
               ) {
                TRACE('Datei ' . $entry->stringify . ' wird gelöscht.'); 
                $geloescht += -s $entry->stringify;
                if (unlink $entry->stringify) {
                    INFO($entry . " wurde geloescht!");
                }    
                else {
                    WARN("Loeschen von " . $entry . " fehlgeschlagen: $!");    
                }
            }
            else {
                WARN($entry . " kann nicht geloescht werden!\n");          
            }
        }            
    }
}

