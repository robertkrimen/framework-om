package Framework::Om::Kit;

use strict;
use warnings;

use Moose;

use Path::Class;
use MooseX::Types::Path::Class qw/Dir File/;

#with 'Framework::Om::Role::Kit';

has home_dir => qw/is ro coerce 1 lazy_build 1/, isa => Dir;
sub _build_home_dir {
    return Path::Class::Dir->new("./")->absolute;
}

sub BUILD {
    my $self = shift;
    $self->factory->prepare_kit($self);
}

1;
