package Framework::Om::Kit;

use strict;
use warnings;

use Moose;

use Path::Class;
use MooseX::Types::Path::Class qw/Dir File/;

use Clone qw/clone/;

use Framework::Om::Processor::Render;
use Framework::Om::Processor::Setup;
use Framework::Om::Build;

#with 'Framework::Om::Role::Kit';

has plugin_list => qw/is ro required 1 isa ArrayRef/, default => sub { [] };
has plugin_map => qw/is ro required 1 isa HashRef/, default => sub { {} };
sub plugins {
    return @{ shift->plugin_list };
}
sub plugin {
    my $self = shift;
    return $self->plugin_map unless @_;
    my $name = shift;
    return $self->plugin_map->{$name};
}

has home_dir => qw/is ro coerce 1 lazy_build 1/, isa => Dir;
sub _build_home_dir {
    return Path::Class::Dir->new( './' )->absolute;
}

sub BUILD {
    my $self = shift;
    $self->factory->prepare_kit( $self );
}

sub parse_render_manifest {
    my $self = shift;
    $self->factory->parse_render_manifest( $self, @_ );
}

has _render => qw/is ro lazy_build 1/, handles => {qw/ render_manifest manifest render_dispatcher dispatcher /};
sub _build__render {
    my $self = shift;
    return Framework::Om::Processor::Render->new( kit => $self );
}

has _setup => qw/is ro lazy_build 1/, handles => {qw/ setup_manifest manifest setup_dispatcher dispatcher /};
sub _build__setup {
    my $self = shift;
    return Framework::Om::Processor::Setup->new( kit => $self );
}

has _build => qw/is ro lazy_build 1/, handles => {qw/ publish publish_dir /};
sub _build__build {
    my $self = shift;
    return Framework::Om::Build->new( kit => $self );
}

sub render {
    shift->_render->process( @_ );
}

sub setup {
    shift->_setup->process( @_ );
}

sub build {
    my $self = shift;
    $self->render;
}

1;
