package Framework::Om::Plugin::Render::TT;

use warnings;
use strict;

use Moose;
use Framework::Om::Plugin;

use Template;
use Carp;

sub parse {
    my $self = shift;
    my $context = shift;
    while (@_) {
        local $_ = shift;
        if ($_ =~ m/\n/) {
            my $list = $_;
            for (split m/\n/, $list) {
                next if m/^\s*$/ || m/^\s*#/;
                my ($path, $template, $comment) = m/^\s*([^#\s]+)(?:\s*([^#\s]+))?(?:\s*#\s*(.*))?$/;
                my $entry = $context->manifest->add( path => $path );
                $entry->process({ plugin => 'Render::TT', template => $template });
            }
        }
        else {
            die "Not ready yet!";
        }
    }
}

has template => qw/is ro lazy_build 1/;
sub _build_template {
    my $self = shift;
    return Template->new({
        INCLUDE_PATH => [ $self->include_path ],
    });
}

sub include_path {
    my $self = shift;
    return $self->kit->assets_tt_dir.'',
}

my $map_path_to_tt = sub {
    my $self = shift;
    my $context = shift;
    my $path = $context->path;
    $path =~ s/^\///;
    if ($path eq '' || $path =~ m/\/$/) {
        for my $include_path ($self->include_path) {
            for (qw/ index.tt.html home.tt.html /) {
                my $tt = "$include_path/$path$_";
                return "$path$_" if -f $tt;
            }
        }
        $path = '/' if $path eq '';
        croak "Unable to find tt file for path $path";
    }
    elsif ($path =~ s/(\.\w{1,4})$/.tt$1/) {
    }
    else {
        $path .= '.tt.html';
    }
    return $path;
};

sub process {
    my $self = shift;
    my $context = shift;

    my $template = $context->process->{template};
    $template = $map_path_to_tt->( $self, $context ) unless $template;

    my $content;
    $self->template->process(
        $template,
        { Context => $context, %{ $context->stash } },
        \$content
    ) or die $self->template->error;

    $context->result->content_type( 'text/html' ) unless $context->result->content_type;
    $context->result->content( $content );
}

1;

__END__

package Framework::Redmash::Render::TT;

use Framework::Redmash::Carp;
use Framework::Redmash::Types;

my $map_path_to_tt = sub {
    my $context = shift;
    my $path = $context->path;
    $path =~ s/^\///;
    if ($path eq '' || $path =~ m/\/$/) {
        for my $include_path ($context->kit->tt->include_path) {
            for (qw/ index.tt.html home.tt.html /) {
                my $tt = "$include_path/$path$_";
                return "$path$_" if -f $tt;
            }
        }
        $path = '/' if $path eq '';
        croak "Unable to find tt file for path $path";
    }
    elsif ($path =~ s/(\.\w{1,4})$/.tt$1/) {
    }
    else {
        $path .= '.tt.html';
    }
    return $path;
};

my $map_context_to_input = sub {
    my $context = shift;
    my $arguments = shift;
    return $context->stash->{template_input} if $context->stash->{template_input};
    return $context->stash->{template} if $context->stash->{template};
    return $arguments->{template_input} if $arguments->{template_input};
    return $arguments->{template} if $arguments->{template};
    return $map_path_to_tt->($context);
};

my $map_context_to_output = sub {
    my $context = shift;
    my $arguments = shift;
    return $context->stash->{template_output} if $context->stash->{template_output};
    return $arguments->{template_output} if $arguments->{template_output};
    my $path = $map_path_to_tt->($context);
    $path =~ s/\.tt(\.\w{1,4})$/$1/;
    return $context->kit->rsc->child($path);
};

sub render {
    my $self = shift;
    my $context = shift;
    my $arguments = shift || {};

    if (ref $arguments eq '') {
        $arguments = { template_input => $arguments };
    }

    my $input = $map_context_to_input->($context, $arguments);
    my $output = $map_context_to_output->($context, $arguments);

    my $file;
    if ($output->can('file')) {
        $file = $output->file;
    }
    elsif ($output->isa('Path::Class::File')) {
        $file = $output
    }

    if ($file && -f $file || -s _) {
        return $output unless $context->kit->testing;
    }

    $context->kit->tt->process(
        input => $input,
        context => { context => $context, %{ $context->stash } },
        output => $output
    );

    return $output;
}

1;
