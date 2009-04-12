package Framework::Om::Plugin::Render::TT;

use warnings;
use strict;

use Moose;
use Framework::Om::Plugin;

use Template;

sub parse {
    my $self = shift;
    my $context = shift;
    while (@_) {
        local $_ = shift;
        if ($_ =~ m/\n/) {
            my $list = $_;
            for (split m/\n/, $list) {
                next if m/^\s*$/ || m/^\s*#/;
                my ($path, $action) = m/^\s*([^\s]+)(?:\s*(.*))?$/;
                my $entry = $context->manifest->add( path => $path );
                if ($action) {
                    $context->factory->setup_action( $entry => $action );
                }
            }
        }
        else {
            die "Not ready yet!";
        }
    }
}

sub load_factory {
    my $self = shift;
    my $factory = shift;

    my $kit_class = $factory->kit_class;

    MooseX::Scaffold->scaffold(class => $kit_class, scaffolder => sub {
        my $class = shift;
        $class->has(tt => qw/is ro lazy_build 1 isa Template/);
        $kit_class->meta->add_method(_build_tt => sub {
            my $self = shift;
            return Template->new({
                INCLUDE_PATH => [ $self->home_dir.'' ],
            });
        });
    });
}

1;
