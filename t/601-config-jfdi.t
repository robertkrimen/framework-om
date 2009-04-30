#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Om::Manifest;

plan qw/no_plan/;

package t::Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/-name Project -identifier project Config::JFDI/;

package main;

my $project = t::Project->new( home_dir => 't/assets/home' );
ok( $project->config );
is( $project->config->{xyzzy}, 1 );
is( $project->config->{uri}, 'http://example.com' );
