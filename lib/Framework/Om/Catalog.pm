package Framework::Om::Catalog;

use strict;
use warnings;

use Moose;

use Framework::Om::Manifest;
use Framework::Om::Dispatcher;

has manifest => qw/is ro lazy_build 1/;
sub _build_manifest {
    return Framework::Om::Manifest->new;
}

has dispatcher => qw/is ro lazy_build 1/;
sub _build_dispatcher {
    return Framework::Om::Dispatcher->new;
}

1;
