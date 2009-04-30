#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package t::Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/-name Project -identifier project Config::JFDI Starter/;

package main;

use Directory::Scratch;
my $scratch = Directory::Scratch->new;

my $project = t::Project->new( home_dir => $scratch->base );

ok( $project );
ok( $project->factory );
ok( $project->_config );
ok( $project->plugin( 'Config::JFDI' ) );
ok( $project->plugin( 'Config::JFDI' )->isa( 'Framework::Om::Plugin::Config::JFDI' ) );
like( $project->setup_manifest->entry( 'assets/root/static/css/project.css' )->content, qr/text-decoration: underline/ );
ok( t::Project->can( 'assets_dir' ) );
ok( ! t::Project->can( 'assets_root_static_css_project_css_dir' ) );
ok( ! -e $scratch->file( 'assets' ) );
ok( ! -e $scratch->file( 'assets/root/static/css/project.css' ) );
$project->setup;
ok( -e $scratch->file( 'assets' ) );
ok( -e $scratch->file( 'assets/root/static/css/project.css' ) );
ok( -s _ );

#|-- assets
#|   |-- root
#|   |   `-- static
#|   |       |-- css
#|   |       |   `-- project.css
#|   |       `-- js
#|   `-- tt
#|       |-- common.tt.html
#|       `-- frame.tt.html
#`-- run
#    |-- root
#    `-- tmp

