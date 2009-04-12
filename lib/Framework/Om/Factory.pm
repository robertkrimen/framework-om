package Framework::Om::Factory;

use strict;
use warnings;

use Moose;
use MooseX::Types::Path::Class qw/File Dir/;

use Framework::Om::Define;

has [qw/ name identifier /] => qw/is rw isa Str/;

has kit_class => qw/is ro required 1 isa Str/;
sub kit_meta {
    return shift->kit_class->meta;
}

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


has setup_manifest => qw/is ro required 1 lazy_build 1/;
sub _build_setup_manifest {
    return Framework::Om::Manifest->new;
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
            if ($argument eq 'name') {
                $self->name( shift @given );
            }
            elsif ($argument eq 'identifier') {
                $self->identifier( shift @given );
            }
            next;
        }
        push @plugins, $argument;
    }

    while (@plugins) {
        my $plugin = shift @plugins;
        my $plugin_class = $plugin;
        unless ($plugin_class =~ s/^\+//) {
            my $name = $plugin_class;
            $plugin_class = "Framework::Om::Plugin::$plugin_class";
            push @{ $self->plugin_list }, $plugin_class;
            $self->plugin_map->{$name} = $self->plugin_map->{$plugin_class} = $plugin_class;
            MooseX::Scaffold->load_class($plugin_class);
            # warn "This will expose errors? ", $plugin_class->isa( 'Framework::Om::Plugin' );
            $plugin_class->load_factory($self);
        }
    }

    $self->prepare_setup_manifest;

    }

sub prepare_setup_manifest {
    my $self = shift;

    for my $plugin ($self->plugins) {
        if ($plugin->can( 'load_setup_manifest' )) {
            $plugin->load_setup_manifest( $self );
        }
    }

    my $class = $self->kit_class;
    my $meta = $self->kit_meta;
    $self->setup_manifest->each(sub {
        my $entry = shift;
        return if $entry->content;
        my $path = $entry->path;
        my @path = split m/\//, $path;
        my $last_dir = pop @path;

        my $dir = join "_", @path, $last_dir;
        my $parent_dir = @path ? join "_", @path : qw/home/;

        my $dir_method = "${dir}_dir";
        my $parent_dir_method = "${parent_dir}_dir";
        $dir_method =~ s/\W/_/g;
        $parent_dir_method =~ s/\W/_/g;

        next if $class->can( $dir_method );

        $meta->add_attribute( $dir_method => qw/is rw required 1 coerce 1 lazy 1/, isa => Dir, default => sub {
            return shift->$parent_dir_method->subdir( $last_dir );
        }, @_ );
    });
}

sub prepare_kit {
    my $self = shift;
    my $kit = shift;

    for my $plugin ($self->plugins) {
        if ($plugin->can( 'load_kit' )) {
            $plugin->load_kit( $self, $kit );
        }
    }
}

sub parse_render_manifest {
    my $self = shift;
    my $kit = shift;

    my $context = Framework::Om::Define::Context->new( factory => $self, kit => $kit, );
    $context->manifest( $kit->render_manifest );
    $context->dispatcher( $kit->render_dispatcher );

    my $parser = shift;
    if (blessed $parser && $parser->can( 'parse' )) {
    }
    else {
        my $plugin_class = $self->plugin( $parser );
        $parser = Framework::Om::Define::Parser->new( parser => $plugin_class->can( 'parse' ) );
    }

    $context->include( $parser => @_ );
}

1;
