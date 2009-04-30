#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'Framework::Om' );
}

diag( "Testing Framework::Om $Framework::Om::VERSION, Perl $], $^X" );
