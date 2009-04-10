#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

use Framework::Om::Dispatcher;

plan qw/no_plan/;

ok(1);

{
    my $dispatcher = Framework::Om::Dispatcher->new;
    ok( $dispatcher );
}
