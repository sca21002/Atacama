use utf8;
use strict;
use warnings;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin, 'lib')->stringify,
        dir($Bin)->parent->subdir(qw(Remedi lib))->stringify;
use Plack::Builder;
use Plack::Middleware::Debug;
use English qw( -no_match_vars ) ;            # Avoids regex performance penalty
use Atacama;
my $app = Atacama->apply_default_middlewares(Atacama->psgi_app); 
my $panels = Plack::Middleware::Debug->default_panels;

# Plack::Middleware::Debug::Memory uses 'ps ...' to get memory infos (only Unix)
if ($OSNAME eq 'MSWin32') {
    $panels = [ grep { $_ ne 'Memory' } @$panels ];
}
builder {
    enable_if { $ENV{ATACAMA_DEBUG} }  'Debug',
        panels =>['DBIC::QueryLog', 'Log4perl', @$panels];
    $app;
};
