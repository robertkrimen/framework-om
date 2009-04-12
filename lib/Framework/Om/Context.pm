package Framework::Om::Context;

use Moose;
#use Document::Stembolt;

has path => qw/is ro required 1/;

has [qw/control stash/] => qw/is ro isa HashRef/, default => sub { {} };

#has document => qw/is ro lazy_build 1/;
#sub _build_document {
#    return Document::Stembolt->new;
#}

1;
