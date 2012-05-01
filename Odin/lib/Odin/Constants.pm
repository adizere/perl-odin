package Odin::Constants;

use strict;
use warnings;

=head1 NAME

Odin::Constants - Constants definitions

=cut

use base qw( Odin Exporter );

use Package::Constants;


=head2

Some remarks:

B<Paths:>

All paths are relative to the path in $ENV{ODIN_HOME} and should have a leading '/'.

B<Tags:>

It is preferable to export multiple constants that are needed together through
the use of the %EXPORT_TAGS variable, such that when importing them only the
tag is used.

Example:

In Odin:Constants:

    our %EXPORT_TAGS = (
        server =>   [ qw(
                        CONST1 CONST2 CONST3 CONST4 CONST5 CONST6 CONST7
                    ) ],
    );

and in the module where these constants are needed:

    use Odin::Constants qw( :server );

rather than:

    use Odin::Constants qw( CONST1 CONST2 CONST3 CONST4 CONST5 CONST6 CONST7 );


=cut

use constant {

    CONFIGURATION_FPATH => '/conf/server_conf.json',

};

our %EXPORT_TAGS = ();

our @EXPORT_OK = Package::Constants->list( __PACKAGE__ );


1;
