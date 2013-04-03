use Plack::Builder;
use Plack::Middleware::Debug;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, 'lib'),
        File::Spec->catfile($Bin, qw(.. Remedi lib));
use English qw( -no_match_vars ) ;            # Avoids regex performance penalty
use Atacama;
my $app = Atacama->apply_default_middlewares(Atacama->psgi_app); 
my $panels = Plack::Middleware::Debug->default_panels;

# Plack::Middleware::Debug::Memory uses 'ps ...' to get memory infos (only Unix)
if ($OSNAME eq 'MSWin32') {
    $panels = [ grep { $_ ne 'Memory' } @$panels ];
}

builder {
  enable_if { $ENV{ATACAMA_DEBUG} } 'DBIC::QueryLog';
  enable_if { $ENV{ATACAMA_DEBUG} } 'Debug',
    panels =>['DBIC::QueryLog', 'Log4perl', @$panels]; 
  $app;
};
