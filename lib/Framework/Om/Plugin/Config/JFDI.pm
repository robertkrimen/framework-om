package Framework::Om::Plugin::Config::JFDI;

use warnings;
use strict;

use Moose;

use Config::JFDI;

sub load_factory {
    my $self = shift;
    my $factory = shift;

    my $kit_class = $factory->kit_class;

    MooseX::Scaffold->scaffold(class => $kit_class, scaffolder => sub {
        my $class = shift;
        $class->has(_config => qw/is ro lazy_build 1 isa Config::JFDI/);
        $kit_class->meta->add_method(_build__config => sub {
            my $self = shift;
            return Config::JFDI->new(path => $self->home_dir.'', name => $factory->identifier);
        });
        $kit_class->meta->add_method(config => sub {
            return shift->_config->get;
        });
        $kit_class->meta->add_method(cfg => sub {
            return shift->config;
        });
    });
}

1;
