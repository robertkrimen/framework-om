package Framework::Om::Plugin::Starter;

use warnings;
use strict;

use Moose;
use Framework::Om::Plugin;

define->setup->action(sub {
    my ($context) = @_;

    $context->do( 'starter/base.css' => \ <<_END_ );
body, table {
    font-family: Verdana, Arial, sans-serif;
    background-color: #fff;
}

a, a:hover, a:active, a:visited {
    text-decoration: none;
    font-weight: bold;
    color: #436b95;
}

a:hover {
    text-decoration: underline;
}

table.bare td {
    border: none;
}

ul.bare {
    margin: 0;
    padding: 0;
}

ul.bare li {
    margin: 0;
    padding: 0;
    list-style: none;
}

div.clear {
    clear: both;
}
_END_

    $context->do( 'starter/base.js' => \ <<_END_ );
_END_

} );

define->setup->path(sub {
    my ($context) = @_;

    my $identifier = $context->identifier;

    $context->include( parser( 'Setup' ), <<_END_ );
run
run/root
run/tmp
assets
assets/root
assets/root/static
assets/root/static/css
assets/root/static/js
assets/tt
assets/root/static/css/$identifier.css  starter/base.css
assets/tt/frame.tt.html                 starter/frame.tt.html
assets/tt/common.tt.html                starter/common.tt.html
_END_

});

1;
