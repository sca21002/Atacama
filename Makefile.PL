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
requires 'Crypt::DES';
requires 'Crypt::Eksblowfish::Bcrypt';
requires 'Crypt::Eksblowfish::Uklblowfish';
requires 'Crypt::MySQL';
requires 'Crypt::PasswdMD5';
requires 'Crypt::UnixCrypt_XS';
requires 'Data::Entropy::Algorithms';
requires 'Digest::MD4';
requires 'Params::Classify';
requires 'Authen::Passphrase';
requires 'Catalyst::Runtime' => '5.80029';
requires 'Catalyst::ActionRole::RequireSSL';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::TraitFor::Model::DBIC::Schema::QueryLog::AdoptPlack';
requires 'Algorithm::Merge';
requires 'Archive::Zip';
requires 'CAM::PDF';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Authentication::Store::LDAP';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Model::File';
requires 'Catalyst::Action::RenderView';
requires 'CatalystX::DebugFilter';
requires 'CatalystX::SimpleLogin';
requires 'Config::ZOMG';
requires 'Data::Page';
requires 'DateTime::Format::Mail';
requires 'DBD::mysql';
requires 'DBIx::Class';
requires 'DBIx::Class::DateTime::Epoch';
requires 'DBIx::Class::EncodedColumn';
requires 'DBIx::Class::PassphraseColumn';
requires 'File::MMagic';
requires 'File::Path';
requires 'Hash::Flatten';
requires 'HTML::FormHandler';
requires 'HTML::FormHandler::Model::DBIC';
requires 'Image::ExifTool';                  # because of AtacamaWiki
requires 'Image::Math::Constrain';
requires 'Imager';
requires 'Path::Iterator::Rule';
requires 'Plack::Middleware::Debug';
requires 'Plack::Middleware::Debug::DBIC::QueryLog';
requires 'Plack::Middleware::Debug::Log4perl';
requires 'YAML::XS';
requires 'List::Util';
requires 'Log::Log4perl';
requires 'Modern::Perl';
requires 'Moose';
requires 'MooseX::ClassAttribute';
requires 'MooseX::MarkAsMethods';
requires 'MooseX::NonMoose';
requires 'MooseX::Types::Combine';
requires 'MooseX::Types::DateTime';
requires 'Number::Format';
requires 'Regexp::Common';
requires 'Text::Textile';
requires 'Template::Plugin::Latex';
requires 'namespace::autoclean';
requires 'TheSchwartz',
requires 'Unicode::UTF8',  # speed up for Path::Tiny::slurp
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
