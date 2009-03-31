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
