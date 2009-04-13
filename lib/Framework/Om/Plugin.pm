package Framework::Om::Plugin;

use warnings;
use strict;

use Moose;
use MooseX::Scaffold;
use MooseX::ClassAttribute;
#use Moose::Exporter;
#my ($import, $unimport) = Moose::Exporter->build_import_methods(
#    with_caller => [ 'define', 'parser' ],
#);
use Sub::Exporter;
my ($import) = Sub::Exporter::build_exporter({
    exports => [
        define => sub {
            my ($caller) = caller 3;
            my $define = Framework::Om::Factory::Define::define->new( stash => Framework::Om::Plugin->plugin_stash->{$caller} ||= {} );
            return sub {
                return $define;
            };
        },
        parser => sub {
            my ($caller) = caller 3;
            return sub {
                my $query = shift;
                my $package = "Framework::Om::Plugin::$query";
                MooseX::Scaffold->load_class( $package );
                return Framework::Om::Factory::Define::Parser->new( parser => $package->can( 'parse' ) );
            };
        },
    ],
    groups => {
        default => [qw/ define parser /],
    },
});
MooseX::Scaffold->setup_scaffolding_import( chain_import => $import );

use Framework::Om::Factory;
use Framework::Om::Factory::Define;

class_has plugin_stash => qw/is ro isa HashRef/, default => sub { {} };

sub SCAFFOLD {
    my $class = shift;

    $class->extends( 'Framework::Om::Kit::Plugin' );
#    $class->class_has( plugin_meta => qw/is ro isa HashRef/, default => sub { {} } );
#    $class->class_has( _define => qw/is ro lazy 1/, default => sub {
#        return Framework::Om::Factory::Define::define->new( plugin_class => $class->name );
#    } );
}

#sub define {
#    my $caller = shift;
#    return $caller->_define( @_ );
#}

#sub parser {
#    my $caller = shift;
#    my $query = shift;
#    my $package = "Framework::Om::Plugin::$query";
#    
#    MooseX::Scaffold->load_class( $package );
#    return Framework::Om::Factory::Define::Parser->new( parser => $package->can( 'parse' ) );
#}

1;

__END__

package Framework::Om::Plugin::_parser;

use Moose;

has parser => qw/is ro isa CodeRef/;

sub parse {
    return shift->parser->( @_ );
}

package Framework::Om::Plugin::_context;

use Moose;

has plugin_class => qw/is ro required 1/;
has kit => qw/is ro required 0/, handles => [qw/ name identifier /];
has factory => qw/is ro required 1/;

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

package Framework::Om::Plugin::_base;

use Moose;
use MooseX::ClassAttribute;

sub load_factory {
    my $self = shift;
    my $factory = shift;

    my $context =  Framework::Om::Plugin::_context->new( factory => $factory, plugin_class => $self );

    $context->action( $factory->setup_action );
    for my $code (@{ $self->plugin_meta->{setup_action} }) {
        $code->($context);
    }

    $context->action( $factory->render_action );
    for my $code (@{ $self->plugin_meta->{render_action} }) {
        $code->($context);
    }
}

sub load_kit {
    my $self = shift;
    my $factory = shift;
    my $kit = shift;

    my $context =  Framework::Om::Plugin::_context->new( kit => $kit, factory => $factory, plugin_class => $self );

    $context->manifest( $kit->setup_manifest );
    $context->dispatcher( $kit->setup_dispatcher );
    for my $code (@{ $self->plugin_meta->{setup_path} }) {
        $code->($context);
    }

    $context->manifest( $kit->render_manifest );
    $context->dispatcher( $kit->render_dispatcher );
    for my $code (@{ $self->plugin_meta->{render_path} }) {
        $code->($context);
    }
}

#sub define {
#    return shift->_define( @_ );
#}

package Framework::Om::Plugin::_define;

use Moose;

has plugin_class => qw/is ro/;

has setup => qw/is ro lazy 1/, default => sub {
    my $self = shift;
    return Framework::Om::Plugin::_define_setup->new( plugin_class => $self->plugin_class );
};

has render => qw/is ro lazy 1/, default => sub {
    my $self = shift;
    return Framework::Om::Plugin::_define_render->new( plugin_class => $self->plugin_class );
};

package Framework::Om::Plugin::_define_setup;

use Moose;

has plugin_class => qw/is ro/;

sub path {
    my $self = shift;
    my $code = shift;
    push @{ $self->plugin_class->plugin_meta->{setup_path} }, $code;
}

sub action {
    my $self = shift;
    my $code = shift;
    push @{ $self->plugin_class->plugin_meta->{setup_action} }, $code;
}

package Framework::Om::Plugin::_define_render;

use Moose;

has plugin_class => qw/is ro/;

sub path {
    my $self = shift;
    my $code = shift;
    push @{ $self->plugin_class->plugin_meta->{render_path} }, $code;
}

sub action {
    my $self = shift;
    my $code = shift;
    push @{ $self->plugin_class->plugin_meta->{render_action} }, $code;
}

1;
