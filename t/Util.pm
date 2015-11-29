package t::Util;
use strict;
use warnings;
use utf8;

use Test::mysqld;

BEGIN {
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '', # no TCP socket
        }
    ) or die $Test::mysqld::errstr;

    $TEST_GUARDS::MYSQLD = $mysqld;
    $ENV{TEST_MYSQL}     = $mysqld->dsn;

    END { undef $TEST_GUARDS::MYDSLD }
}

1;
__END__

