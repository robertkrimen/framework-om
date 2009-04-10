package Framework::Om::Dispatcher;

use Moose;

use Path::Dispatcher;
use Path::Dispatcher::Builder;

has dispatcher => qw/is ro lazy_build 1/;
sub _build_dispatcher {
    my $self = shift;
    return $self->builder->dispatcher;
}

has builder => qw/is ro lazy_build 1/;
sub _build_builder {
    return Path::Dispatcher::Builder->new;
    
}

sub dispatch {
    my $self = shift;
    return $self->dispatcher->dispatch( @_ );
}

1;
