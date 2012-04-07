package Odin::Conf;

use strict;
use warnings;

use base qw ( Exporter );

use Config::JSON;
use Cwd;

our @EXPORT_OK = qw( $json_config $conf );

# TODO: no hard-coding here
my $json_config = Config::JSON->new( pathToFile => getcwd . '/conf/server_conf.json' );
our $conf = $json_config->config();


1;
