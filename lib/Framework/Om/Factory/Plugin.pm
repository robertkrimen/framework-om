package Framework::Om::Factory::Plugin;

use Moose;
use MooseX::ClassAttribute;

has name => qw/is ro required 1/;
has class => qw/is ro required 1/;
has config => qw/is ro required 1/;
has factory => qw/is ro required 1/;

sub stash {
    my $self = shift;
    return Framework::Om::Plugin->plugin_stash->{$self->class} ||= {};
}

sub load_factory {
    my $self = shift;
    my $factory = shift;

    for my $code (@{ $self->stash->{load_factory} }) {
        $code->($factory);
    }

    my $context =  Framework::Om::Factory::Define::Context->new( factory => $factory, plugin_class => $self );

    $context->action( $factory->setup_action );
    for my $code (@{ $self->stash->{setup_action} }) {
        $code->($context);
    }

    $context->action( $factory->render_action );
    for my $code (@{ $self->stash->{render_action} }) {
        $code->($context);
    }
}

sub load_kit {
    my $self = shift;
    my $kit = shift;

    my $factory = $self->factory;

    for my $code (@{ $self->stash->{load_kit} }) {
        $code->($factory, $kit);
    }

    my $context = Framework::Om::Factory::Define::Context->new( kit => $kit, factory => $factory, plugin_class => $self );

    $context->manifest( $kit->setup_manifest );
    $context->dispatcher( $kit->setup_dispatcher );
    $self->load_setup_path( $context );

    $context->manifest( $kit->render_manifest );
    $context->dispatcher( $kit->render_dispatcher );
    $self->load_render_path( $context );
}

sub load_setup_manifest {
    my $self = shift;
    my $factory = $self->factory;

    my $context = Framework::Om::Factory::Define::Context->new( factory => $factory, plugin_class => $self );

    $context->manifest( $factory->setup_manifest );
    $context->dispatcher( undef );
    $self->load_setup_path( $context );
}

sub load_setup_path {
    my $self = shift;
    my $context = shift;

    for my $code (@{ $self->stash->{setup_path} }) {
        $code->($context);
    }
}

sub load_render_path {
    my $self = shift;
    my $context = shift;

    for my $code (@{ $self->stash->{render_path} }) {
        $code->($context);
    }

}

1;
