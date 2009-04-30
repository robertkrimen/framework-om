package Framework::Om::Plugin::URI;

use warnings;
use strict;

use Moose;
use Framework::Om::Plugin;
use Carp;

use Path::Resource;
use URI::PathAbstract;

define->load_factory(sub {
    my $factory = shift;

    my $kit_class = $factory->kit_class;

    MooseX::Scaffold->scaffold(class => $kit_class, scaffolder => sub {
        my $class = shift;
        $kit_class->meta->add_method( uri => sub {
            my $self = shift;
            return $self->plugin( 'URI' )->uri( @_ );
        });
    });

    MooseX::Scaffold->scaffold(class => $kit_class, scaffolder => sub {
        my $class = shift;
        $kit_class->meta->add_method( rsc => sub {
            my $self = shift;
            return $self->plugin( 'URI' )->rsc( @_ );
        });
    });
});

has rsc => qw/is ro lazy_build 1 isa Path::Resource/;
sub _build_rsc {
    my $self = shift;
    return Path::Resource->new(uri => $self->uri, dir => $self->kit->run_root_dir);
}

has uri => qw/is ro lazy_build 1 isa URI::PathAbstract/;
sub _build_uri {
    my $self = shift;
    my $method = "build_uri";
    croak "Don't have method \"$method\"" unless my $build = $self->can($method);
    my $got = $build->($self, @_);

    return $got if blessed $got && $got->isa("URI::PathAbstract");
    return URI::PathAbstract->new($got);
}

sub build_uri {
    my $self = shift;
    my $uri = $self->kit->config->{uri};
    die "No uri is specified in config" unless $uri;
    return $uri;
}

1;
