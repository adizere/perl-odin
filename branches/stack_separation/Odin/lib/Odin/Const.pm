package Odin::Const;

use strict;
use warnings;

=head1 NAME

Odin::Const - Constants definitions

=cut

use base qw( Odin Exporter );

use Internals qw( SetReadOnly );

my $const = {

};


SetReadOnly( $const );


our @EXPORT_OK = qw( $const );


1;
