use Plack::Builder;
use Plack::Middleware::Debug;
use FindBin qw($Bin);
use File::Spec;
use lib File::Spec->catfile($Bin, 'lib'),
        File::Spec->catfile($Bin, qw(.. Remedi lib));
use Atacama;
my $app = Atacama->apply_default_middlewares(Atacama->psgi_app); 
my $panels = Plack::Middleware::Debug->default_panels;
 
builder {
  enable_if { $ENV{ATACAMA_DEBUG} } 'DBIC::QueryLog';
  enable_if { $ENV{ATACAMA_DEBUG} } 'Debug::CatalystLog';
  enable_if { $ENV{ATACAMA_DEBUG} } 'Debug',
    panels =>['CatalystLog','DBIC::QueryLog', @$panels];
  $app;
};
