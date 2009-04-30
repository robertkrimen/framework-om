package Framework::Om::Render;

use strict;
use warnings;

use Moose;
extends 'Framework::Om::Processor';

sub BUILD {
    my $self = shift;

    $self->postprocessor->{DEFAULT} = 'write';
    $self->postprocessor->{write} = sub {
        my $self = shift;
        my ($context, %given) = @_;

        my $result = $context->result;
        my $extension;
        $extension = '.html' if $result->content_type eq 'text/html';
        
        die "Don't know how to write out result" unless $extension;

        my $file = $given{file};
        if ($file) {
            $file = $file->file if blessed $file && $file->isa( 'Path::Resource' );
        }
        else {
            $file = $context->path;
            $file .= 'index' if $file =~ m/\/$/;
            $file = "$file$extension";
        }
        $file = $self->kit->run_root_dir->file( $file ) unless blessed $file;
        $file->parent->mkpath unless -d $file->parent;
        $file->openw->print( $result->content );
    };
}

1;
