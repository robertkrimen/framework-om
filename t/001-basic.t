#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/Config::JFDI Starter/;
with 'Framework::Om::Role::Kit';

sub identifier { 'project' }
sub name { 'Project' }

package main;

my $project = Project->new;

ok($project);
ok($project->factory);
ok($project->_config);
