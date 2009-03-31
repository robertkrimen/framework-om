=pod

PathDispatch
PathDispatch::Context

prepare
run
finish

before_*
after_*

Do any naming through standard Perl mechanisms (subroutine, package, etc.)

=cut

package Framework::Orangemash::PathFetch;

use strict;
use warnings;

sub test {

    my $pf = PathFetch->new(
        parser => sub { },
        parse_ignore => sub { },
        parse_by_line => 1)
    # Custom entry parsing

    my ($target, $entry);

    $target = $pf->target(path => 'a');
    $target = $pf->target(path => 'a/b/c', rank => 1);
    $target = $pf->target(match => qr/.*/, rank => 1);
    $entry = $pf->entry(path => 'a', data => { qw/a b c d/ });

    $pf->find( '...' );

}

# PathFetch
# PathFetch::Manifest
# PathFetch::Finder

#!/usr/bin/perl -w

use strict;
use warnings;

my $factory = undef;

sub register {
    
    $factory->setup_at( 'yui.css' )->use( 'yui/all.css' )
    $factory->setup_at( 'yui.js' )->use( 'yui/all.js' )
    $factory->setup_at( '$identifier.css' )->use( 'starter/base.css' )
    $factory->setup_at( '$identifier.js' )->use( 'starter/base.js' )

    $factory->manifest->setup( 'location' => 'handler' )
    $factory->manifest->render( 'location' => 'handler' )
    $factory->manifest->render( 'location' )

    $factory->handler( 'location' )->around( '...' )
    $factory->handler( 'location' )->set( '...' )
    $factory->handler( 'location' )->replace( '...' )
    $factory->handler( 'location' )->before( '...' )
    $factory->handler( 'location' )->after( '...' )

    $factory->handler( 'location' )->set( sub { 
        my ($path, $part) = @_;
    } );

    $factory->manifest( 'location' )->setup( '...' )
    $factory->manifest( 'location' )->render( '...' )
    $factory->manifest( 'location' )->render

    $factory->prepare_setup( 'path' => '...' )
    $factory->prepare_render( 'path' => '...' )
    $factory->prepare_render( 'path' )
    $factory->install_setup_handler( 'path' => '...'  )
    $factory->install_render_handler( 'path' => '...'  )

    # An action is more generic than setup/render

    $factory->setup_path( 'path' => '...' )
    $factory->render_path( 'path' => '...' )
    $factory->render_path( 'path' )
    $factory->setup_action( 'path' => '...' )
    $factory->render_action( 'path' => '...' )

    $factory->setup_action( 'path' => '...' )
    $factory->render_action( 'path' => '...' )
    $factory->render( 'path' )
    $factory->setup_method( 'path' => '...' )
    $factory->render_method( 'path' => '...' )
    $factory->setup_method( 'path' => '>namespace:' )
    
}

package MyProject;

use Framework::Orangemash qw//;

package Framework::Orange::Plugin::Starter;

use strict;
use warnings;

sub register {

    my ($factory) = @_;

    my $identifier = $factory->identifier;

    {
        # This stuff is general purpose, can be used even if 
        # user doesn't want a standard layout (below)
        my $plugin = $factory->plugin( base => 'starter' )
        $plugin->setup_action( 'base.css' => '...' )
            $factory->setup_action_pf->entry( path => 'starter/base.css', data => {
                method => '...',
            } );
        $plugin->setup_action( 'base.js' => '...' )
        $plugin->setup_action( '.june8/base.js' => '...' )

    }

    # Here is the standard layout
    $factory->setup_manifest( <<_END_ )
run
run/root
run/tmp
assets
assets/root
assets/root/static
assets/root/static/css
assets/root/static/js
assets/tt
_END_
        $factory->setup_file_pf->entry( path => 'run' );
        $factory->setup_file_pf->entry( path => 'assets/tt' );

    $factory->setup_manifest( "assets/root/static/css/$identifier.css" => 'starter/base.css' )
        # This interpolation can be done at runtime
        $factory->setup_file_pf->entry( path => "assets/root/static/css/$identifier.css", data => {
            content => 'starter/base.css',
        } );
    $factory->setup_manifest( 'assets/root/static/js/$identifier.js' => 'starter/base.js' )

    # _target is an alias for _manifest/_file
    $factory->render_target( qr/.*$/, => 'tt/render' )

    # Maybe use ->on_setup or ->on_render as an alias as well?
}

package Framework::Orange::Plugin:TT;

use strict;
use warnings;

sub register {

    my ($factory) = @_;

    {
        my $plugin = $factory->plugin( base => 'tt' )
        $plugin->render_action( 'render' => sub {
        } )
    }
}

1;
