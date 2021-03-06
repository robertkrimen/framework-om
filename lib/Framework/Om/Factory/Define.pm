package Framework::Om::Factory::Define;

use warnings;
use strict;

package Framework::Om::Factory::Define::Parser;

use Moose;

has parser => qw/is ro isa CodeRef/;

sub parse {
    return shift->parser->( @_ );
}

package Framework::Om::Factory::Define::Context;

use Moose;

#has plugin_class => qw/is ro required 0/;
has kit => qw/is ro required 0/;
has factory => qw/is ro required 1/, handles => [qw/ name identifier /];

has manifest => qw/is rw/;
has dispatcher => qw/is rw/;
has action => qw/is rw/;

sub include {
    my $self = shift;
    
    if (blessed $_[0] && $_[0]->can( 'parse' )) {
        my $parser = shift;
        $parser->parse( $self, @_ );
    }
    else {
        die "Don't know what to do!"
    }
}

sub do {
    my $self = shift;
    my $path = shift;
    my $action = shift;

    $self->action->{$path} = $action;
}

#package Framework::Om::Define::Plugin;

#use Moose;
#use MooseX::ClassAttribute;

#sub load_factory {
#    my $self = shift;
#    my $factory = shift;

#    my $context =  Framework::Om::Define::Context->new( factory => $factory, plugin_class => $self );

#    $context->action( $factory->setup_action );
#    for my $code (@{ $self->plugin_meta->{setup_action} }) {
#        $code->($context);
#    }

#    $context->action( $factory->render_action );
#    for my $code (@{ $self->plugin_meta->{render_action} }) {
#        $code->($context);
#    }
#}

#sub load_kit {
#    my $self = shift;
#    my $factory = shift;
#    my $kit = shift;

#    my $context = Framework::Om::Define::Context->new( kit => $kit, factory => $factory, plugin_class => $self );

#    $context->manifest( $kit->setup_manifest );
#    $context->dispatcher( $kit->setup_dispatcher );
#    $self->load_setup_path( $context );

#    $context->manifest( $kit->render_manifest );
#    $context->dispatcher( $kit->render_dispatcher );
#    $self->load_render_path( $context );
#}

#sub load_setup_manifest {
#    my $self = shift;
#    my $factory = shift;

#    my $context = Framework::Om::Define::Context->new( factory => $factory, plugin_class => $self );

#    $context->manifest( $factory->setup_manifest );
#    $context->dispatcher( undef );
#    $self->load_setup_path( $context );
#}

#sub load_setup_path {
#    my $self = shift;
#    my $context = shift;

#    for my $code (@{ $self->plugin_meta->{setup_path} }) {
#        $code->($context);
#    }
#}

#sub load_render_path {
#    my $self = shift;
#    my $context = shift;

#    for my $code (@{ $self->plugin_meta->{render_path} }) {
#        $code->($context);
#    }

#}

package Framework::Om::Factory::Define::define;

use Moose;

has stash => qw/is ro required 1 isa HashRef/;

has setup => qw/is ro lazy 1/, default => sub {
    my $self = shift;
    return Framework::Om::Factory::Define::define::setup->new( stash => $self->stash );
};

has render => qw/is ro lazy 1/, default => sub {
    my $self = shift;
    return Framework::Om::Factory::Define::define::render->new( stash => $self->stash );
};

sub load_factory {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{load_factory} }, $code;
}

sub load_kit {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{load_kit} }, $code;
}

package Framework::Om::Factory::Define::define::setup;

use Moose;

has stash => qw/is ro required 1 isa HashRef/;

sub path {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{setup_path} }, $code;
}

sub action {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{setup_action} }, $code;
}

package Framework::Om::Factory::Define::define::render;

use Moose;

has stash => qw/is ro required 1 isa HashRef/;

sub path {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{render_path} }, $code;
}

sub action {
    my $self = shift;
    my $code = shift;
    push @{ $self->stash->{render_action} }, $code;
}

1;
