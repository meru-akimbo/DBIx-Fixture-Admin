use strict;
use Test::More 0.98;
use t::Util;

use DBIx::Fixture::Admin;
use DBIx::Sunny;

my $dbh = DBIx::Sunny->connect( $ENV{TEST_MYSQL} );

sub teardown {
    eval {
        $dbh->query("DROP TABLE `test_hoge`");
    };

    my @create_sqls = (
        "CREATE TABLE `test_hoge` (
          `id` integer unsigned NOT NULL auto_increment,
          `name` VARCHAR(32) NOT NULL,
          PRIMARY KEY (`id`)
        );",

        "CREATE TABLE `test_huga` (
          `id` integer unsigned NOT NULL auto_increment,
          `name` VARCHAR(32) NOT NULL,
          PRIMARY KEY (`id`)
        );",
    );

    $dbh->query($_) for @create_sqls;
}


subtest 'basic' => sub {
    my $admin = DBIx::Fixture::Admin->new(
        dbh  => $dbh,
        conf => +{
            fixture_path  => './t/fixture/yaml/',
            ignore_tables => ['test_hoge']
        }
    );

    my @data = $admin->_build_create_data(['test_hoge', 'test_huga']);

    is scalar @data, 1;
    is $data[0]->{table}, 'test_huga';
    is $data[0]->{pk},    'id';

};

done_testing;

