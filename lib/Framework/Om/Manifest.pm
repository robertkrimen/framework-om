package Framework::Om::Manifest;

use Moose;

has parser => qw/is ro required 1 isa CodeRef/, default => sub { sub {
    my $self = shift;
    chomp;
    return if m/^\s*$/ || m/^\s*#/;
    my ($path, $comment) = m/^\s*([^#\s]+)(?:\s*#\s*(.*))?$/;
    s/^\s*//, s/\s*$// for $path;
    $self->add(path => $path, comment => $comment);
} };
has _entry_list => qw/is ro required 1/, default => sub { {} };

sub _entry {
    my $self = shift;
    return $_[0] if @_ == 1 && blessed $_[0];
    return Framework::Om::Manifest::Entry->new(@_);
}

sub entry_list {
    return shift->_entry_list;
}

sub entry {
    my $self = shift;
    return $self->_entry_list unless @_;
    my $path = shift;
    return $self->_entry_list->{$path};
}

sub all {
    my $self = shift;
    return sort { $a cmp $b } keys %{ $self->_entry_list };
}

sub add {
    my $self = shift;
    my $entry = $self->_entry(@_);
    $self->_entry_list->{$entry->path} = $entry;
}

sub each {
    my $self = shift;
    my $code = shift;

    for (sort keys %{ $self->_entry_list }) {
        $code->($self->entry->{$_})
    }
}

sub include {
    my $self = shift;

    while (@_) {
        local $_ = shift;
        if ($_ =~ m/\n/) {
            $self->_include_list($_);
        }
        else {
            my $path = $_;
            my %entry;
            %entry = %{ shift() } if ref $_[0] eq 'HASH';
            # FIXME Should we do it this way?
            my $comment = delete $entry{comment};
            $self->add(path => $_, comment => $comment, stash => { %entry });
        }
    }
}

sub _include_list {
    my $self = shift;
    my $list = shift;

    for (split m/\n/, $list) {
        $self->parser->($self);
    }
}

package Framework::Om::Manifest::Entry;

use Moose;

has path => qw/is ro required 1/;
has comment => qw/is ro isa Maybe[Str]/;
has stash => qw/is ro required 1 isa HashRef/, default => sub { {} };
has process => qw/is rw isa Maybe[Str|HashRef]/;

sub content {
    return shift->stash->{content};
}

sub copy_into {
    my $self = shift;
    my $hash = shift;
    while (my ($key, $value) = each %{ $self->stash }) {
        $hash->{$key} = $value;
    }
}

1;
