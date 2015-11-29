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


subtest 'can fixture load' => sub {
    teardown;

    my $select_hoge_sql = "SELECT * FROM test_hoge;";
    my $rows = $dbh->select_all($select_hoge_sql);
    is scalar @$rows, 0;

    my $admin = DBIx::Fixture::Admin->new(
        dbh  => $dbh,
        conf => +{
            fixture_path  => './t/fixture/yaml/',
            ignore_tables => ['test_huga'],
        }
    );

    $admin->load(tables => ['test_hoge', 'test_huga']);
    $rows = $dbh->select_all($select_hoge_sql);
    is scalar @$rows, 3;

    $rows = $dbh->select_all("SELECT * FROM test_huga;");
    is scalar @$rows, 0;
};

done_testing;

