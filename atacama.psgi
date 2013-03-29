use Plack::Builder;
use Plack::Middleware::Debug;
use Atacama;
 
my $app = Atacama->psgi_app;
my $panels = Plack::Middleware::Debug->default_panels;
 
builder {
  enable 'DBIC::QueryLog';
  enable 'Debug::CatalystLog';
  enable 'Debug', panels =>['DBIC::QueryLog', @$panels];
  $app;
};