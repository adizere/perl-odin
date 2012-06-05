package Odin;

use strict;
use warnings;

=head1 NAME

Odin - Distributed socket server framework

=head1 VERSION

Version 0.001

=cut

use vars qw( $VERSION );
our $VERSION = "0.001";

=head1 DESCRIPTION

Top hierarchy class.
Has 2 roles:

* It keeps the version of the module.
* It loads the $ENV{ODIN_HOME} environment variable needed throughout the project
for locating files relative to our project working directory.

=cut


# Automagically set the ODIN_HOME directory
$ENV{ODIN_HOME} = _get_conf_path();

sub _get_conf_path {
    my $this_name = __PACKAGE__;

    # from Odin to Odin.pm
    # WARNING: If it were Module::Odin, then transform to Module/Odin.pm
    $this_name .= '.pm';

    my $this_path = $INC{$this_name};

    # remove the trailing lib/Odin.pm
    $this_path =~ s/lib\/$this_name//g;

    # now we've got the full path to the directory holding the project
    return $this_path;
}


=head1 AUTHOR

Adi Seredinschi, C<< <adizere at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Adi Seredinschi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1; # End of Odin
