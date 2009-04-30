package Framework::Om::Setup;

use strict;
use warnings;

use Moose;
extends 'Framework::Om::Processor';

sub BUILD {
    my $self = shift;

    $self->postprocessor->{DEFAULT} = 'write';
    $self->postprocessor->{write} = sub {
        my $self = shift;
        my ($context) = @_;

        my $file = $self->kit->home_dir->file( $context->path );
        return if -e $file;
        # TODO Better designator... maybe in the Setup plugin?
        if (defined $context->stash->{content}) {
            $file->parent->mkpath unless -d $file->parent;
            $file->openw->print($context->stash->{content});
        }
        else {
            my $dir = Path::Class::Dir->new( $file );
            $dir->mkpath;
        }
    };
}

1;
