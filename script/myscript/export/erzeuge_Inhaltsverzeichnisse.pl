#!/usr/bin/env perl
use strict;
use JSON;
use Text::CSV;
use Path::Tiny;
use XML::LibXML;
use XML::LibXSLT;
use LWP::UserAgent;

my $doc;
my $csvfile='VHVO_Kapitel.csv';
my $downloadpath='VHVO-Download'; # Pfad relativ zum Mountpunkt rzblx8.uni-regensburg.de:/media/nss/DATA2/digitalisierung/digitool : /medien_ubr/digitool2


# CSV-Liste aus der Rückversorgungsliste einlesen
my @lines = path('test.csv')->lines;
shift @lines; #Ueberschrift

my @result=("pid;ID;Kapitelueberschrift;ErsteSeite;LetzteSeite;Anzahl_Seiten;PID_ersteSeite;Anzahl_weitereGliederungsebenen;DeeplinkingUrl\n");
# xslt-Stylesheet laden
my $xslt = XML::LibXSLT->new();
my $style_doc = XML::LibXML->load_xml(location=>'VHVO_Toc2csv.xsl', no_cdata=>1);
my $stylesheet = $xslt->parse_stylesheet($style_doc);

#write_list();
download_files();

sub download_files{
  # Kapitel herunterladen
  my @lines = path($csvfile)->lines;
  shift @lines; #Ueberschrift
  foreach my $line (@lines){
    my ($pid,$id)=split ';',$line;
    my $url="http://digipool.bib-bvb.de/bvb/anwender/Download_per_http/print_VHVO.pl?metsid=$pid&ids=$id&parta=DE-355&unit=BAY01&path=$downloadpath";
	# übrigens mehrere IDs kann man über ',' verbunden als Parameter ids übergeben
    print "url: ", $url;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET=>$url);
    my $res = $ua->request($req);
    if ($res->is_success) {
        print $res->content; # Hier kommt als text/plain der vollständige Dateipfad zurück. Dateiname ist sprintf("%s_%s.pdf",$metsid,$ids)
    }
    else {
       die "Error: " .$res->status_line; # Hier sollte mit Status 400 die Fehlermeldung zurückkommen
    }
  }
}

sub write_list{
  # csv-Datei mit Kapiteln erzeugen
  my $i=0;
  open my $out, ">$csvfile" or  die "cannot open $csvfile: $!";;
  print $out "pid;ID;Kapitelueberschrift;ErsteSeite;LetzteSeite;Anzahl_Seiten;PID_ersteSeite;Anzahl_weitereGliederungsebenen;DeeplinkingUrl\n";
  foreach my $line (@lines){
    my ($pid)=split ';',$line;
    $i++;
    print "$i: $pid\n";
    print $out process_pid($pid);
  }
  close $out;
}


sub process_pid{
   my $pid=shift;

   my $jsonstr=get_Toc($pid); 
   my $jsondata = decode_json $jsonstr;
   $doc = XML::LibXML::Document->createDocument( "1.0", "UTF-8" );
   my $root = $doc->createElement('root');
   $root->setAttribute('PID',$pid);
   $doc->setDocumentElement($root);
   processJsondata($jsondata->[0],$root);
   #print $doc->toFile("test.xml",1);
   my $results = $stylesheet->transform($doc);
   return $stylesheet->output_as_bytes($results);
 }

sub get_Toc{
  my $pid=shift;
  
  my $url="http://digital.bib-bvb.de/view/bvbmets/getStructMap.jsp?pid=$pid&parta=DE-355&au=BAY01";
  
  my $jsonstr='';    
  my $ua = LWP::UserAgent->new;
  my $req = HTTP::Request->new(GET=>$url);
  my $res = $ua->request($req);
       # Check the outcome of the response
  if ($res->is_success) {
        $jsonstr=$res->content;
  }
  else {
    die "Could not fetch json for pid:'$pid' " .$res->status_line;
  }
  return $jsonstr;  
}
sub processJsondata{
  my $data=shift;
  my $node=shift;
  
  $node->setAttribute( 'LABEL', $data->{data} );
  my $pid=$data->{attr}->{pid};
  if ($pid){
   $node->setAttribute( 'PID', $pid );
   $node->setAttribute( 'ID', $data->{attr}->{id} );
  }
  else{
     $node->setAttribute( 'ID', $data->{attr}->{id} );
  }
  return if (!$data->{children});
  my @children=@{$data->{children}} ;
  foreach my $child_data (@children){
      my $elementname=($child_data->{attr}->{pid})?'pg':'ch';
      my $child_node=$node->addChild($doc->createElement($elementname));  
      processJsondata($child_data,$child_node);
   }
}    
