package Framework::Om::Kit;

use strict;
use warnings;

use Moose;

use Path::Class;
use MooseX::Types::Path::Class qw/Dir File/;

use Framework::Om::Manifest;
use Framework::Om::Dispatcher;
use Framework::Om::Context;

#with 'Framework::Om::Role::Kit';

has home_dir => qw/is ro coerce 1 lazy_build 1/, isa => Dir;
sub _build_home_dir {
    return Path::Class::Dir->new( './' )->absolute;
}

has render_manifest => qw/is ro required 1 lazy_build 1/;
sub _build_render_manifest {
    return Framework::Om::Manifest->new;
}

has render_dispatcher => qw/is ro required 1 lazy_build 1/;
sub _build_render_dispatcher {
    return Framework::Om::Dispatcher->new;
}

has setup_manifest => qw/is ro required 1 lazy_build 1/;
sub _build_setup_manifest {
    return Framework::Om::Manifest->new;
}

has setup_dispatcher => qw/is ro required 1 lazy_build 1/;
sub _build_setup_dispatcher {
    return Framework::Om::Dispatcher->new;
}

sub BUILD {
    my $self = shift;
    $self->factory->prepare_kit( $self );
}

sub parse_render_manifest {
    my $self = shift;
    $self->factory->parse_render_manifest( $self, @_ );
}

sub load_render_context {
    my $self = shift;
    my ($context) = @_;

    if (my $entry = $self->render_manifest->entry( $context->path )) {
        $entry->copy_into( $context->stash );
    }
}

sub prepare_render {
    my $self = shift;
    my ($context) = @_;

    $self->load_render_context( $context );
}

sub new_render_context {
    my $self = shift;
    my ($path) = @_;

    return Framework::Om::Context->new( path => $path );
}

sub render {
    my $self = shift;
    my ($path) = @_;

    my $context = $self->new_render_context( $path );

    $self->prepare_render( $context );

    $self->dispatch_render( $context );

    return $self->finalize_render( $context );
}

sub dispatch_render {
    my $self = shift;
    my ($context) = @_;

    my $dispatch = $self->render_dispatcher->dispatch( $context->path );
    return unless $dispatch;
    return $dispatch->run( $context );
}

sub finalize_render {
    my ($context) = @_;
}

sub load_setup_context {
    my $self = shift;
    my ($context) = @_;

    if (my $entry = $self->setup_manifest->entry( $context->path )) {
        $entry->copy_into( $context->stash );
    }
}

sub prepare_setup {
    my $self = shift;
    my ($context) = @_;

    $self->load_setup_context( $context );
}

sub new_setup_context {
    my $self = shift;
    my ($path) = @_;

    return Framework::Om::Context->new( path => $path );
}

sub setup {
    my $self = shift;
    if (@_) {
        my ($path) = @_;

        my $context = $self->new_setup_context( $path );

        $self->prepare_setup( $context );

        $self->dispatch_setup( $context );

        return $self->finalize_setup( $context );
    }
    else {
        for my $path ($self->setup_manifest->all) {
            $self->setup( $path );
        }
    }
}

sub dispatch_setup {
    my $self = shift;
    my ($context) = @_;

    my $dispatch = $self->setup_dispatcher->dispatch( $context->path );
    return unless $dispatch;
    return $dispatch->run( $context );
}

sub finalize_setup {
    my $self = shift;
    my ($context) = @_;

    my $file = $self->home_dir->file( $context->path );
    return if -e $file;
    if ($context->stash->{content}) {
        $file->parent->mkpath unless -d $file->parent;
        $file->openw->print($context->stash->{content});
    }
    else {
        my $dir = dir $file;
        $dir->mkpath;
    }
}

1;
