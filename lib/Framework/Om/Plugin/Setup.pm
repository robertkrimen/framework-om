package Framework::Om::Plugin::Setup;

use warnings;
use strict;

use Moose;

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

1;
