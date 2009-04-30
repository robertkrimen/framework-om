package Framework::Om::Context;

use Moose;

has kit => qw/is ro required 1/;
has path => qw/is ro required 1/;

has stash => qw/is rw isa HashRef/, default => sub { {} };
has process => qw/is rw isa Maybe[Str|HashRef]/;
has postprocess => qw/is rw isa Maybe[Str|HashRef|ArrayRef]/;
has result => qw/is rw lazy_build 1/;
sub _build_result {
    return Framework::Om::Context::Result->new;
}

package Framework::Om::Context::Result;

use Moose;

has data => qw/is rw/, default => sub { {} };
has type => qw/is rw/;
has content => qw/is rw/;
has content_type => qw/is rw/;

1;
