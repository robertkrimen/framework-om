package Framework::Om::Processor::Render;

use strict;
use warnings;

use Moose;
extends qw/ Framework::Om::Processor /;

with qw/ Framework::Om::Processor::Does::Disk /;

sub base_dir {
    return shift->kit->run_root_dir;
}

sub resolve_file {
    my $self = shift;
    my $context = shift;

    my $file = $self->file_from_post_process( $context );

    if (blessed $file) {
        $file = $file->file if  $file->isa( 'Path::Resource' );
    }
    else {
        unless ( defined $file ) {
            my $result = $context->result;
            my $extension;
            $extension = '.html' if $result->content_type eq 'text/html';

            die "Don't know how to write out result" unless $extension;

            $file = $context->path;
            $file .= 'index' if $file =~ m/\/$/;
            $file = "$file$extension";
        }

        $file = $self->base_dir->file( $file );
    }

    return $file;
}

override post_process => sub {
    my $self = shift;
    my $context = shift;

    my $file = $self->resolve_file( $context );

    $self->write_file( $file, $context->result->content );
};

1;
