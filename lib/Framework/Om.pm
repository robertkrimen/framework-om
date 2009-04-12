package Framework::Om;

use warnings;
use strict;

=head1 NAME

Framework::Om -

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use MooseX::Scaffold;
MooseX::Scaffold->setup_scaffolding_import;

use Framework::Om::Factory;
use Framework::Om::Kit;

sub SCAFFOLD {
    my $class = shift;

    $class->extends( 'Framework::Om::Kit' );

#    $class->with('Framework::Om::Role::Kit');

    $class->class_has( factory =>
        qw/is ro isa Framework::Om::Factory/,
        default => sub {
            return Framework::Om::Factory->new( kit_class => $class->name );
        },
        handles => [qw/ plugin /],
    );

    $class->name->factory->prepare_factory( @_ );
}


=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-framework-om at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Framework-Om>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Framework::Om


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Framework-Om>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Framework-Om>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Framework-Om>

=item * Search CPAN

L<http://search.cpan.org/dist/Framework-Om/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Framework::Om
