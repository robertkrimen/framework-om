package Framework::Om::Processor::Does::Disk;

use strict;
use warnings;

use Moose::Role;

use Path::Class;

requires qw/ resolve_file base_dir /;

sub file_from_post_process {
    my $self = shift;
    my $context = shift;

    my $post_process = $context->post_process;
    return $post_process if blessed $post_process;
    return $post_process->{file} if ref $post_process eq 'HASH';
    return undef;
}

sub write_file {
    my $self = shift;
    my $file = shift;
    my $content = shift;

    $file->parent->mkpath unless -d $file->parent;
    $file->openw->print( $content );
}

1;
