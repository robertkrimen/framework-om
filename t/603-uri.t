#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Om::Manifest;

plan qw/no_plan/;

package t::Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/-name Project -identifier project Config::JFDI Starter Render::TT URI/;

package main;

my $project = t::Project->new( home_dir => 't/assets/home' );
ok( $project->config );
is( $project->config->{uri}, 'http://example.com' );
ok( $project->uri );
ok( $project->rsc );
is( $project->uri.'', 'http://example.com' );

__END__

use Directory::Scratch;
my $scratch = Directory::Scratch->new;

my $project = t::Project->new;
$project->run_root_dir( $scratch->base );

ok( ! $project->render_manifest->entry( '/this' ) );
$project->parse_render_manifest( 'Render::TT' => <<_END_ );
    # Skip this line
/

    /this.html

# Previous line should be skipped
/this     # This is a comment for /this
/that/#Comment with no gap

/comment-and-content comment-and-content.tt.html # This is the comment
/just-content just-content.tt.html
_END_

ok( $project->render_manifest->entry( '/this' ) );
is( $project->render_manifest->entry( '/this' )->process->{template}, undef );
ok( $project->plugin( 'Render::TT' ) );
ok( $project->plugin( 'Render::TT' )->template );

$project->render( '/' );
ok( -e $scratch->file( 'index.html' ) );

