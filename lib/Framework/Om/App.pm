package Framework::Om::App;

use strict;
use warnings;

use Getopt::Chain;
use Class::Inspector;
use Path::Class;

my $ABORT = sub {
    print STDERR join "", '! ', @_, "\n";
    exit -1;
};
sub abort {
    $ABORT->(@_);
}

my $REPORT = sub {
    print STDOUT join "", '# ', @_, "\n";
};
sub report {
    $REPORT->(@_);
}

my $HOME = dir '.';
sub home() {
    return $HOME;
}

sub om_file {
    return home->file(".om");
}

sub package_filename {
    return Class::Inspector->resolved_filename(shift, '.');
}

sub discover {
    my $om_file = om_file;

    abort "File .om desn't exist (did you init?)" unless -e $om_file;

    my $package = $om_file->slurp;
    chomp $package;

    abort "File .om does not contain a package name" unless $package; 

    eval "require $package;" or abort "Unable to load $package since: $@";
#    my $om_meta = $package->om_meta;
    my $om_meta;

    return ($om_file, $package, $om_meta);
}

sub run {
    my $self = shift;
    {
        my $given = {};
        $given = shift if ref $_[0] eq 'HASH';

        $ABORT = $given->{abort} if $given->{abort};
        $REPORT = $given->{report} if $given->{report};
        $HOME = dir $given->{home} if $given->{home};
    }

    Getopt::Chain->process(
    
        (@_ ? \@_ : ()),

        commands => {

            christen => sub {
                my $ctx = shift;
                my $package = shift;

                abort "Wasn't given a package to christen" unless $package;

                my $package_filename = package_filename $package or abort "Couldn't find file for package $package";

            
                report "package = $package";
                report "package filename = $package_filename";

                my $om_file = om_file;

                # TODO Need some sort of check here (or warning)
                # abort "File .om already exists" if -e $om_file;

                $om_file->openw->print("$package\n");

                eval "require $package;" or abort "Unable to load $package since: $@";

                my $kit = $package->new;
                $kit->setup;
#                my $om_meta = $package->om_meta;

#                my $setup_manifest = $om_meta->setup_manifest;
#                $setup_manifest->each(sub {
#                    my $file = shift;
#                    my $home_file = home->file($file->path);
#                    return if -e $home_file;
#                    if ($file->content) {
#                        $home_file->parent->mkpath unless -d $home_file->parent;
#                        $home_file->openw->print($file->content);
#                    }
#                    else {
#                        $home_file = dir $home_file;
#                        $home_file->mkpath;
#                    }
#                });
            },

            build => sub {
                my $ctx = shift;

                my ($om_file, $package, $om_meta) = discover;

                my $kit = $package->new;
                $kit->{home_dir} = home;

                $kit->build;
            },
            
            about => sub {
                my $ctx = shift;

                my ($om_file, $package, $om_meta) = discover;

                report ".om = $om_file";
                report "package = $package";

#                my $om_file = om_file;

#                abort "File .om desn't exist (did you init?)" unless -e $om_file;

#                my $package = $om_file->slurp;
#                chomp $package;

#                abort "File .om does not contain a package name" unless $package; 

#                report ".om = $om_file";
#                report "package = $package";

#                eval "require $package;" or abort "Unable to load $package since: $@";
#                my $om_meta = $package->om_meta;

##                report "base = ", $om_meta->base;

                report "setup_manifest =";
                my $setup_manifest = $om_meta->setup_manifest;
                $setup_manifest->each(sub {
                    my $file = shift;
                    report "\t", $file->path, (defined $file->comment ? (' # ', $file->comment) : ());
                });
            },
            
        },

    );
}

1;

