package Framework::Om::Context;

use Moose;

has path => qw/is ro required 1/;

has [qw/control stash/] => qw/is ro isa HashRef/, default => sub { {} };

1;
