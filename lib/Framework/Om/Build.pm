package Framework::Om::Build;

use strict;
use warnings;

use Moose;

use Carp;
use File::Copy;
use File::Spec::Link;
use File::Find;

has kit => qw/is ro required 1/, handles => [qw/ plugin /];

sub publish_dir {
    my $self = shift;
    my $kit = $self->kit;
    if (1 == @_) {
        return $self->publish_dir( from_dir => shift, to_dir => $kit->run_root_dir, @_ );
    }
    my %given = @_;

    my $from_dir = $given{from_dir} || $given{from} or croak "Wasn't given a dir to copy from";
    my $to_dir = $given{to_dir} || $given{to} or croak "Wasn't given a dir (or path) to copy to";
    my $copy = $given{copy};
    my $skip = $given{skip} || qr/^(?:\.svn|.git|CVS|RCS|SCCS)$/;

    find { no_chdir => 1, wanted => sub {
        my $from = $_;
        if ($from =~ $skip) {
            $File::Find::prune = 1;
            return;
        }
        my $from_relative = substr $from, length $from_dir;
        my $to = "$to_dir/$from_relative";

        return if -e $to || -l $to;
        if (! -l $from && -d _) {
            dir( $to )->mkpath;
        }
        else {
            if ($copy) {
                File::Copy::copy( $from, $to ) or warn "Couldn't copy($from, $to): $!";
            }
            else {
                my $from = File::Spec::Link->resolve( $from ) || $from;
                $from = file( $from )->absolute;
                symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
            }
        }
    } }, $from_dir;
}

sub publish {
    my $self = shift;
    my $kit = $self->kit;
    if (1 == @_) {
        return $self->publish( from => shift, to => $kit->run_root_dir, @_ );
    }
    my %given = @_;

    my $from = $given{from} or croak "Wasn't given a path to copy from";
    my $to = $given{to} or croak "Wasn't given a path to copy to";
    my $copy = $given{copy};

    if (-f $from && -d $to) {
        croak "Given a file to copy ($from) but destination is a directory ($to)";
    }

    return $self->publish_dir( @_ ) unless -f $from;

    my $dir = file($to)->parent;
    $dir->mkpath unless -d $dir;

    if ($copy) {
        File::Copy::copy( $from, $to ) or warn "Couldn't copy($from, $to): $!";
    }
    else {
        return if -l $to;
        my $from = File::Spec::Link->resolve( $from ) || $from;
        $from = file( $from )->absolute;
        symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
    }
}

1;
