#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use File::Copy::Recursive;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Atacama';
all_from 'lib/Atacama.pm';

requires 'aliased';
requires 'Catalyst::Runtime' => '5.80029';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Algorithm::Merge';
requires 'Archive::Zip';
requires 'CAM::PDF';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Model::File';
requires 'Catalyst::Action::RenderView';
requires 'CatalystX::SimpleLogin';
requires 'Config::ZOMG';
requires 'Data::Page';
requires 'DateTime::Format::Mail';
requires 'DBD::mysql';
requires 'DBIx::Class::DateTime::Epoch';
requires 'DBIx::Class::EncodedColumn';
requires 'File::MMagic';
requires 'File::Path';
requires 'HTML::FormHandler';
requires 'HTML::FormHandler::Model::DBIC';
requires 'Image::ExifTool';                  # because of AtacamaWiki
requires 'Image::Math::Constrain';
requires 'Imager';
requires 'YAML::XS';
requires 'List::Util';
requires 'Log::Log4perl';
requires 'Moose';
requires 'MooseX::ClassAttribute';
requires 'MooseX::NonMoose';
requires 'MooseX::Types::Path::Class';
requires 'MooseX::Types::DateTime';
requires 'Number::Format';
requires 'Text::Textile';
requires 'Template::Plugin::Latex';
requires 'namespace::autoclean';
requires 'TheSchwartz',
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
