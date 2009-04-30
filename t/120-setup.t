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
$project->setup;

ok( -d $scratch->file( 'run' ) );
ok( -f $scratch->file( 'assets/root/static/css/project.css' ) );
