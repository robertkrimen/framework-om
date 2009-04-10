#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package t::Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/Config::JFDI Starter/;
with 'Framework::Om::Role::Kit';

sub identifier { 'project' }
sub name { 'Project' }

package main;

my $project = t::Project->new;

ok( $project );
ok( $project->factory );
ok( $project->_config );
like( $project->setup_manifest->entry( 'assets/root/static/css/project.css' )->content, qr/text-decoration: underline/ );
