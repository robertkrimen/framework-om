package Framework::Om::Plugin::Config::JFDI;

use warnings;
use strict;

use Moose;
use Framework::Om::Plugin;

use Config::JFDI;

define->load_factory(sub {
    my $factory = shift;

    my $kit_class = $factory->kit_class;

    MooseX::Scaffold->scaffold(class => $kit_class, scaffolder => sub {
        my $class = shift;
        $kit_class->meta->add_method(_config => sub {
            my $self = shift;
            return $self->plugin( 'Config::JFDI' );
        });
        $kit_class->meta->add_method(config => sub {
            return shift->_config->config->get;
        });
        $kit_class->meta->add_method(cfg => sub {
            return shift->config;
        });
    });
});

has config => qw/is ro lazy_build 1 isa Config::JFDI/;
sub _build_config {
    my $self = shift;
    return Config::JFDI->new(path => $self->kit->home_dir.'', name => $self->factory->identifier);
}

1;
