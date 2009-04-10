package Framework::Om::Factory;

use strict;
use warnings;

use Moose;

has kit_class => qw/is ro required 1 isa Str/;
sub kit_meta {
    return shift->kit_class->meta;
}

has _plugins => qw/is ro required 1 isa ArrayRef/, default => sub { [] };
sub plugins {
    return @{ shift->_plugins };
}

has _setup_action => qw/is ro isa HashRef/, default => sub { {} };

has _render_action => qw/is ro isa HashRef/, default => sub { {} };

sub setup_action {
    my $self = shift;
    return $self->_setup_action unless @_;
    
    $self->_action( $self->_setup_action, @_ );
}

sub render_action {
    my $self = shift;
    return $self->_render_action unless @_;

    $self->_action( $self->_render_action, @_ );
}

sub _action {
    my $self = shift;
    my ($action_manifest, $entry, $action_path) = @_;

    my $action = $action_manifest->{$action_path};

    return unless $action;

    if (ref $action eq 'HASH') {
        while (my ($key, $value) = each %$action) {
            $entry->stash->{$key} = $value;
        }
    }
    elsif (ref $action eq 'CODE') {
        $action->($entry);
    }
    elsif (ref $action eq 'SCALAR') {
        $entry->stash->{content} = $$action;
    }
    else {
        die "Don't know what to do with $action";
    }
}

sub prepare_factory {
    my $self = shift;

    my @given = splice @_, 6, -4;
    my @plugins;

    while (@given) {
        my $argument = shift @given;
        if ($argument =~ s/^-//) {
            next;
        }
        push @plugins, $argument;
    }

    while (@plugins) {
        my $plugin = shift @plugins;
        my $plugin_class = $plugin;
        unless ($plugin_class =~ s/^\+//) {
            $plugin_class = "Framework::Om::Plugin::$plugin_class";
            push @{ $self->_plugins }, $plugin_class;
            MooseX::Scaffold->load_class($plugin_class);
            # warn "This will expose errors? ", $plugin_class->isa( 'Framework::Om::Plugin' );
            $plugin_class->load_factory($self);
        }
    }
}

sub prepare_kit {
    my $self = shift;
    my $kit = shift;

    for my $plugin ($self->plugins) {
        if ($plugin->can('load_kit')) {
            $plugin->load_kit($self, $kit);
        }
    }
}

1;
