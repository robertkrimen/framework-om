package Framework::Om::Processor;

use strict;
use warnings;

use Moose;

use Path::Class;
use MooseX::Types::Path::Class qw/Dir File/;

use Framework::Om::Manifest;
use Framework::Om::Dispatcher;
use Framework::Om::Context;
use Clone qw/clone/;

has kit => qw/is ro required 1/, handles => [qw/ plugin /];

has manifest => qw/is ro lazy_build 1/;
sub _build_manifest {
    return Framework::Om::Manifest->new;
}

has dispatcher => qw/is ro lazy_build 1/;
sub _build_dispatcher {
    return Framework::Om::Dispatcher->new;
}

has postprocessor => qw/is ro isa HashRef/, default => sub { {} };

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
        $context = Framework::Om::Context->new( path => $given, kit => $self->kit );
    }
    elsif (ref $given eq 'HASH') {
            
        $context = Framework::Om::Context->new( path => $given->{path}, kit => $self->kit );
        $given->{$_} and $context->$_( $given->{$_} ) for qw/process postprocess stash/;
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

        return $self->postprocess( $context );
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

sub lookup_postprocess {
    my $self = shift;
    my $do = shift;

    $do = $self->postprocessor->{$do} while defined $do && ! ref $do;
    return $do;
}

sub postprocess {
    my $self = shift;
    my ($context) = @_;

    my ($do, @arguments);
    $do = $context->postprocess;
    if ($do) {
        if (ref $do eq 'ARRAY') {
            ($do, @arguments) = @$do;
        }
        elsif (! ref $do) {
        }
        else {
            die "Don't know how to postprocess with $do";
        }
    }
    $do = $self->lookup_postprocess( defined $do ? $do : 'DEFAULT' );

    return unless defined $do;

    die "Don't know how to postprocess with $do" unless ref $do eq 'CODE';

    return $do->( $self, $context, @arguments );
}

1;
