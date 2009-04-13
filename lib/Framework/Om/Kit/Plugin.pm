package Framework::Om::Kit::Plugin;

use Moose;
use MooseX::ClassAttribute;

has factory => qw/is ro required 1/;
has kit => qw/is ro required 1/;

1;
