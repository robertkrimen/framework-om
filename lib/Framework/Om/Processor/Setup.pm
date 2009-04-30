package Framework::Om::Processor::Setup;

use strict;
use warnings;

use Moose;

extends qw/ Framework::Om::Processor /;
with qw/ Framework::Om::Processor::Does::Disk /;

sub base_dir {
    return shift->kit->home_dir;
}

sub resolve_file {
    my $self = shift;
    my $context = shift;

    my $file = $self->file_from_post_process( $context );

    # TODO Check that file is under base_dir
    # TODO Bork if path is absolute?
    $file = $self->base_dir->file( $context->path ) unless blessed $file;

    return $file;
}

override post_process => sub {
    my $self = shift;
    my $context = shift;

    my $file = $self->resolve_file( $context );

    # TODO Better file/dir designator... maybe in the Setup plugin?
    if ( defined( my $content =  $context->stash->{content} ) ) {
        $self->write_file( $file, $content );
    }
    else {
        my $dir = Path::Class::Dir->new( $file );
        $dir->mkpath;
    }
};

1;
