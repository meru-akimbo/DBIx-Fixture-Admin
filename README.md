[![Build Status](https://travis-ci.org/meru-akimbo/DBIx-Fixture-Admin.svg?branch=master)](https://travis-ci.org/meru-akimbo/DBIx-Fixture-Admin)
[![codecov.io](https://codecov.io/github/meru-akimbo/DBIx-Fixture-Admin/coverage.svg?branch=master)](https://codecov.io/github/meru-akimbo/DBIx-Fixture-Admin?branch=master)

# NAME

DBIx::Fixture::Admin - facilitate data management by the fixtures

# SYNOPSIS

    # in perl code
    use DBIx::Fixture::Admin;

    use DBI;
    my $dbh = DBI->connect("DBI:mysql:sample", "root", "");

    my $admin = DBIx::Fixture::Admin->new(
        conf => +{
            fixture_path  => "./fixture/",
            driver        => "mysql",
            load_opt      => "update",
            ignore_tables => ["user_.*", ".*_log"]  # ignore management
        },
        dbh => $dbh,
    );

    $admin->load_all(); # load all fixture
    $admin->create_all(); # create all fixture
    $admin->create(["sample"]); # create sample table fixture
    $admin->load(["sample"]); # load sample table fixture

    # in CLI
    # use config file .fixture in current dir
    # see also .fixture in thish repository
    create-fixture # execute create_all
    load-fixture   # execute load_all

# DESCRIPTION

DBIx::Fixture::Admin is facilitate data management by the fixtures

# LICENSE

Copyright (C) meru\_akimbo.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

meru\_akimbo <merukatoruayu0@gmail.com>
