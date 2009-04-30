package Framework::Om::Processor;

use strict;
use warnings;

use Moose;

use Path::Class;
use MooseX::Types::Path::Class qw/Dir File/;

use Framework::Om::ProcessorContext;
use Framework::Om::Catalog;

use Clone qw/clone/;

has kit => qw/is ro required 1/, handles => [qw/ plugin /];
has catalog => qw/is ro lazy_build 1/, handles => [qw/ manifest dispatcher /];
sub _build_catalog {
    my $self = shift;
    return Framework::Om::Catalog->new( );
}

sub load_context {
    my $self = shift;
    my ($context) = @_;

    if (my $entry = $self->manifest->entry( $context->path )) {
        $context->process( clone $entry->process );
        $entry->copy_into( $context->stash );
    }
}

sub prepare {
    my $self = shift;
    my ($context) = @_;

    $self->load_context( $context );
}

sub new_context {
    my $self = shift;
    my $given = shift;
    my $context;
    if (ref $given eq '') {
        $context = Framework::Om::ProcessorContext->new( path => $given, kit => $self->kit );
    }
    elsif (ref $given eq 'HASH') {
            
        $context = Framework::Om::ProcessorContext->new( path => $given->{path}, kit => $self->kit );
        $given->{$_} and $context->$_( $given->{$_} ) for qw/process post_process process_stash post_process_stash/;
    }

    return $context;
}

sub process {
    my $self = shift;
    if (@_) {
        my $context = $self->new_context( @_ );

        $self->prepare( $context );

        $self->dispatch( $context );

        $self->_process( $context );

        return $self->post_process( $context );
    }
    else {
        for my $path ($self->manifest->all) {
            $self->process( $path );
        }
    }
}

sub _process {
    my $self = shift;
    my ($context) = @_;

    my $process = $context->process;
    if (ref $process eq 'HASH') {
        my $plugin = $process->{plugin};
        die "Couldn't find plugin for $plugin" unless $self->plugin( $plugin );
        $self->plugin( $plugin )->process( $context );
    }
}

sub dispatch {
    my $self = shift;
    my ($context) = @_;

    my $dispatch = $self->dispatcher->dispatch( $context->path );
    return unless $dispatch;
    return unless $dispatch->has_matches;
    return $dispatch->run( $context );
}

sub post_process {
    my $self = shift;
    my ($context) = @_;
}

1;
