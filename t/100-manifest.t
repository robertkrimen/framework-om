#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Om::Manifest;

plan qw/no_plan/;

{
    my $manifest = Framework::Om::Manifest->new;
    $manifest->include(<<_END_);
    # Skip this line
run
run/root

# Previous line should be skipped
run/tmp
assets
assets/root     # This is a comment for assets/root
    assets/root/static
assets/root/static/css
assets/root/static/js#Comment with no gap
_END_

    for (qw(
        run
        run/root
        run/tmp
        assets
        assets/root
        assets/root/static
        assets/root/static/css
        assets/root/static/js
    )) {
        ok($manifest->entry->{$_});
        is($manifest->entry->{$_}->path, $_);
    }

    is($manifest->entry->{'assets/root'}->comment, 'This is a comment for assets/root');
    is($manifest->entry->{'assets/root/static/js'}->comment, 'Comment with no gap');

    $manifest->include(
        'assets/root/static/css/example.css' => {
            content => '/* Some css */',
        },
        'assets/tmp',
        'assets/root/static/js/example.js' => {
            comment => 'This is a .js entry',
        },
    );

    ok($manifest->entry->{'assets/tmp'});
    is($manifest->entry->{'assets/tmp'}->path, 'assets/tmp');

    is($manifest->entry->{'assets/root/static/css/example.css'}->content, '/* Some css */');
    is($manifest->entry->{'assets/root/static/js/example.js'}->comment, 'This is a .js entry');
}
