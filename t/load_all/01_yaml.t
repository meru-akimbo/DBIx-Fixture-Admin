use strict;
use Test::More 0.98;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../../";

use t::Util;

use DBIx::Fixture::Admin;
use DBIx::Sunny;

my $dbh = DBIx::Sunny->connect( $ENV{TEST_MYSQL} );

sub teardown {
    eval {
        $dbh->query("DROP TABLE `test_hoge`");
        $dbh->query("DROP TABLE `test_huga`");
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


subtest 'can load all' => sub {
    teardown;

    my $admin = DBIx::Fixture::Admin->new(
        dbh  => $dbh,
        conf => +{
            fixture_path  => './t/fixture/yaml/',
            fixture_type  => 'yaml',
        }
    );

    $admin->load_all;
    my $rows = $dbh->select_all("SELECT * FROM test_hoge;");
    is scalar @$rows, 3;

    $rows = $dbh->select_all("SELECT * FROM test_huga;");
    is scalar @$rows, 3;
};

subtest 'no such fixture' => sub {
    teardown;
    local $SIG{__WARN__} = sub { fail shift };

    my $admin = DBIx::Fixture::Admin->new(
        dbh  => $dbh,
        conf => +{
            fixture_path  => './t/fixture/yaml/not_exist',
            fixture_type  => 'yaml',
        }
    );

    lives_ok {
        $admin->load_all;
    };
};

done_testing;

