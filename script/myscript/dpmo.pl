#!/usr/bin/perl -w
use strict;
use warnings;
use Text::CSV_XS;
use feature qw(say);
use Getopt::Long;
use Log::Log4perl qw(:easy);
use FindBin;
use Path::Class;
use DateTime::Format::Strptime;
use Config::ZOMG;
use lib "$FindBin::Bin/../../lib";
use Atacama::Schema;
use Net::FTP;

my @head_row_standard = qw(Dateiname Seite Datum Nummer Jahrgang);
my @Wochentage = qw(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);
my $ftp_server = 'rzblx7.uni-regensburg.de';
my $ftp_user   = 'dpmo';
my $ftp_password = 'dpmo';

my $image_dir = 'jpeg';
my $xml_dir = 'xml';

my $csv_filename;

GetOptions(
    "csv=s"    => \$csv_filename,       
);

LOGDIE("Usage dpmo.pl --csv <csv-datei>") unless $csv_filename;
LOGDIE("CSV-Datei $csv_filename nicht gefunden") unless -f $csv_filename;

my $csv_file = Path::Class::File->new($csv_filename);

my $logfile = file($csv_file->dir, 'dpmo.log');
$logfile->dir->mkpath();

my $titlepages_file = Path::Class::File->new($csv_file->dir,'titlepages.list');
my $titlepages_fh = $titlepages_file->openw();

my $dates_file = Path::Class::File->new($csv_file->dir,'dates.list');
my $dates_fh = $dates_file->openw();

my $directory = $csv_file->dir->dir_list(-1);

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

INFO('CSV-Datei: ' . $csv_filename);

my ($filestem) = $csv_file->basename =~ qr/(.*)\.[^.]*$/; 
TRACE("Dateiname ohne Extension " . $filestem);

my ($order_id) = $filestem =~ qr/^(ubr\d{5})/;
INFO("Auftagsnr. " . $order_id);

LOGDIE("Keine Auftragsnummer aus dem Namen der CSV-Datei $filestem ableitbar")
    unless $order_id;
    
my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);

my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{$config_hash->{'Model::AtacamaDB'}{connect_info}}  
);

my $order = $schema_atacama->resultset('Order')->find($order_id);
LOGDIE("Kein Auftrag $order_id in der Datenbank gefunden") unless $order; 
       
my $order_project = $order->orders_projects->search({project_id => 62})->single;
my $projectoption;
my @projectkeys = $order_project->project->projectkeys->all;
foreach my $projectkey (@projectkeys) {
    my $projectvalue = $order_project->search_related(
        'projectvalues',
        { projectkey_id => $projectkey->projectkey_id }
    )->single;
    $projectoption->{$projectkey->pkey} = $projectvalue && $projectvalue->value || '';
    TRACE($projectkey->pkey . " => " . $projectoption->{$projectkey->pkey});
}       

LOGDIE('Jahresangabe fehlt') unless $projectoption->{Jahr};
my $year =  $projectoption->{Jahr};
INFO('Jahrgang: ' . $year);

open my $fh, "<:encoding(cp1252)", $csv_filename
    or LOGDIE "$csv_filename: $!";

my $csv = Text::CSV_XS->new ({ binary => 1 }) or
    die "Cannot use CSV: ".Text::CSV->error_diag ();

my @rows;   
# $csv->eol ("\r\n"); # ging nicht!
$csv->sep_char(";");

while (my $row = $csv->getline ($fh)) {
    push @rows, $row;
}
$csv->eof or $csv->error_diag ();
close $fh;

INFO('Zeilen in der CSV-Datei: ' . scalar(@rows));

my $head_row = shift(@rows);

LOGDIE('Falsche Kopfzeile: '
    . (join '|', @$head_row) . ' <> ' .  (join '|', @head_row_standard) )
    unless (join '', @$head_row) eq (join '', @head_row_standard); 


my @issues;
my $issue_index;
my $page_index;
my $volume;

my $strp = new DateTime::Format::Strptime(
    pattern     => '%d.%m.%Y',
    locale      => 'de_DE',
    on_error    => 'croak',
);

foreach my $row (@rows) {
    my ($scan_filename, $page, $date, $issue, $volume_number) = @$row;
    LOGDIE("Ungueltiger Dateiename " . ($scan_filename||'<leer>')  
           .  ' in Zeile: ' . (join ' ', @$row))
         unless ($scan_filename =~ /^${order_id}_\d{3,5}$/); 
  
    $volume ||= $volume_number;
    LOGDIE('Falscher Jahrgang ' . $volume_number)
        unless $volume eq $volume_number;
    if ( !defined($issue_index) or $issues[$issue_index]->{issue} ne $issue) {
        unless (defined($issue_index)) {
            $issue_index = 0;
        } else {
            if ( $issues[$issue_index]->{issue} =~ /^\d+$/ && $issue =~ /^\d+$/ ) {
               LOGDIE('Falsche Nummerierung ' . $issues[$issue_index]->{issue} . ' --> ' . $issue
                   . ' in Zeile: ' . (join ' ', @$row)
               )
               unless  $issue - $issues[$issue_index]->{issue} == 1;
            }
            $issue_index++; 
        }
        $issues[$issue_index]->{issue} = $issue;
        my $dt = $strp->parse_datetime($date);
        
        if ($issue_index > 0) {
            my $dt_prev = $issues[$issue_index-1]->{dt};
            if (DateTime->compare( $dt_prev, $dt) > 0 ) {
                LOGDIE('Falsches Datum: ' . $date . ' ist früher als '
                    . $issues[$issue_index-1]->{date}
                    . ' in Zeile: ' . (join ' ', @$row)     
                );  
            }
        }
        
        $issues[$issue_index]->{date} = $date;
        $issues[$issue_index]->{dt} = $dt;
        $page_index = 0;
    } else {
        LOGDIE('Falsches Datum ' . $date . ' fuer Ausgabe '
               . $issues[$issue_index]->{issue} . ' vom '
               . $issues[$issue_index]->{date}
        ) unless $issues[$issue_index]->{date}  eq $date;       
    }
    $issues[$issue_index]->{pages}->[$page_index]->{page} = $page,
    $issues[$issue_index]->{pages}->[$page_index]->{scan_filename}
        = $scan_filename;
    $page_index++;
}

INFO('Band: ' . $volume);

my $i;
foreach my $issue (@issues) {
    $i++;
    LOGDIE('Fehlerhafte Zeile (Zeile '.  $i . ') ' .  $issue->{issue} . ' ' . $issue->{date})
        unless $issue->{issue} && $issue->{date};
    INFO('Ausgabe: ' . $issue->{issue} . ' vom ' . $issue->{date} . ' ' . $Wochentage[$issue->{dt}->day_of_week()] );
    if (defined $titlepages_fh) {
        print $titlepages_fh $issue->{pages}->[0]->{scan_filename}, "\n";
    }
    if (defined $dates_fh) {
        print $dates_fh
            join(',',
                $directory,
                $issue->{pages}->[0]->{scan_filename},
                $issue->{dt}->strftime('%Y%m%d'),
            ),
            "\n"
        ;
    }
    
    foreach my $page (@{$issue->{pages}}) {
        INFO('    ' .  $page->{page} . '(' . $page->{scan_filename} . ')');
        LOGDIE('Scandatei zu ' . file($csv_file->dir, $image_dir, $page->{scan_filename} . '.jpg') . ' nicht gefunden')
            unless -f  file($csv_file->dir, $image_dir, $page->{scan_filename} . '.jpg');
        LOGDIE('XML-Datei zu ' . $page->{scan_filename} . ' nicht gefunden')
            unless -f  file($csv_file->dir, $xml_dir, $page->{scan_filename}  . '.xml');    
    }

}

undef $titlepages_fh;
undef $dates_fh;

my $ftp = Net::FTP->new($ftp_server, Debug => 0)
    or LOGDIE "Cannot connect to $ftp_server: $@";
INFO('Connected to ' . $ftp_server);


$ftp->login($ftp_user, $ftp_password)
      or LOGDIE "Cannot login ", $ftp->message;
INFO('Logged in as ' . $ftp_user);     
      
$ftp->cwd(dir('DIFMOE', 'marburger_zeitung'))
    or LOGDIE ("Can't cwd " . dir('DIFMOE', 'marburger_zeitung')->as_foreign('Unix'), ' ' . $ftp->message);

my @dirs = $ftp->ls('data');

foreach my $dir (@dirs) { say 'DIR: ' . $dir }

unless (grep { $_ eq  $year  } @dirs) {

   $ftp->mkdir('data/' . $year)
    or LOGDIE("Can't mkdir data/$year", ' ' . $ftp->message);
    INFO("Created data/$year");
      $ftp->mkdir('images/' . $year)
    or LOGDIE("Can't mkdir images/$year", ' ' . $ftp->message);
    INFO("Created images/$year");
}

$ftp->cwd(dir('images', $year)->as_foreign('Unix'))
    or LOGDIE "Can't cwd " . dir('images', $year)->as_foreign('Unix'), ' ' . $ftp->message;
INFO("Changed to " . dir('images', $year)->as_foreign('Unix'));


$ftp->binary() 
    or LOGDIE ("Can't switch to BINARY mode", ' ' . $ftp->message);

foreach my $issue (@issues) {
   foreach my $page (@{$issue->{pages}}) {
        $ftp->put(file($csv_file->dir, $image_dir, $page->{scan_filename} . '.jpg')->stringify)
            or LOGDIE "Can't put " . file($csv_file->dir, $image_dir, $page->{scan_filename} . '.jpg');
        INFO('put ' . file($csv_file->dir, $image_dir, $page->{scan_filename} . '.jpg'));
   }
}

$ftp->cwd(dir('..', '..', 'data', $year)->as_foreign('Unix'))
    or LOGDIE "Can't cwd " . dir('data', $year)->as_foreign('Unix'), ' ' . $ftp->message;

foreach my $issue (@issues) {
   foreach my $page (@{$issue->{pages}}) {
        $ftp->put(file($csv_file->dir, $xml_dir, $page->{scan_filename}  . '.xml')->stringify)
            or LOGDIE "Can't put " . file($csv_file->dir, $xml_dir, $page->{scan_filename}  . '.xml');
        INFO('put ' . file($csv_file->dir, $xml_dir, $page->{scan_filename}  . '.xml'));
   }
}

$ftp->put(file($csv_file->dir,'titlepages.list')->stringify)
	    or LOGDIE ("Can't put " . file($csv_file->dir,'titlepages.list')); 
$ftp->put(file($csv_file->dir, 'dates.list')->stringify)
            or LOGDIE ("Can't put " . file($csv_file->dir,'dates.list'));


$ftp->quit;   
