package Framework::Om::ProcessorContext;

use Moose;

has kit => qw/is ro required 1/;
has path => qw/is ro required 1/;

has [qw/ process post_process /] => qw/is rw/;
has [qw/ process_stash /] => qw/is rw isa HashRef/, default => sub { {} };

has result => qw/is rw lazy_build 1/;
sub _build_result {
    return Framework::Om::ProcessorContext::Result->new;
}

sub _as_hash($) {
    my $self = shift;
    my $could_be_hash = shift;
    return 'HASH' eq ref $could_be_hash ? $could_be_hash : {};
}

has process_as_hash => qw/is ro lazy_build 1 isa HashRef/;
sub _build_process_as_hash {
    return _as_hash shift->process;
}

has post_process_as_hash => qw/is ro lazy_build 1 isa HashRef/;
sub _build_post_process_as_hash {
    return _as_hash shift->post_process;
}

sub stash {
    return shift->process_stash( @_ );
}

package Framework::Om::ProcessorContext::Result;

use Moose;

has data => qw/is rw/, default => sub { {} };
has type => qw/is rw/;
has content => qw/is rw/;
has content_type => qw/is rw/;

1;
