#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Om::Manifest;

plan qw/no_plan/;

package t::Project;

use Moose;
use MooseX::ClassAttribute;
use Framework::Om qw/-name Project -identifier project Config::JFDI Starter Render::TT/;
with 'Framework::Om::Role::Kit';

package main;

my $project = t::Project->new;
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
ok( $project->plugin( 'Render::TT' ) );
ok( $project->plugin( 'Render::TT' )->template );

#for (qw(
#    /
#    /this.html
#    /this
#    /that/
#    /comment-and-content
#    /just-content
#)) {
#    ok($manifest->entry->{$_});
#    is($manifest->entry->{$_}->path, $_);
#}

#is($manifest->entry->{'/this'}->comment, 'This is a comment for /this');
#is($manifest->entry->{'/that/'}->comment, 'Comment with no gap');
#is($manifest->entry->{'/comment-and-content'}->comment, 'This is the comment');

#is($manifest->entry->{'/comment-and-content'}->content, 'comment-and-content.tt.html');
#is($manifest->entry->{'/just-content'}->content, 'just-content.tt.html');

#$project->render( '/' );

ok(1);
