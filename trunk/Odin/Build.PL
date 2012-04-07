use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Odin',
    license             => 'perl',
    dist_author         => q{Adi Seredinschi <adizere@cpan.org>},
    dist_version_from   => 'lib/Odin.pm',
    build_requires => {
        'Test::More' => '0.9',
        'Class::Accessor::Grouped' => '0.1',
        'Exporter' => '5.65',
        'Config::JSON' => '1.5',
        'Cwd' => '3',
        'IO::Socket::SSL' => '1.50',
        'Sys::Syslog' => '0.27'
    },
    add_to_cleanup      => [ 'Odin-*' ],
);

$builder->create_build_script();
