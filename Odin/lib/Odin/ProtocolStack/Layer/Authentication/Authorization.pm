package Odin::ProtocolStack::Layer::Authentication::Authorization;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Authentication::Authorization

=head1 DESCRIPTION

Authorization is sub-layer of Authentication, it handles the access levels that
are assigned to different peers, based on their credentials.

=cut

use base qw( Odin Class::Accessor );


1;
