#!/usr/local/bin/perl

package CMTest6;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

my @lag = (
    [ 'Team10', 'true', [ 'sw0p14', 'sw0p13' ] ],
    [ 'Team11', 'false', [ 'sw0p15' ] ],
);
my @fdb = (
    [ 'AA:BB:CC:FF:EE:02', '2', 'AA:BB:CC:FF:EE:03', '3' ],
    [ 'AA:BB:CC:ff:EE:04', '4', 'AA:BB:CC:FF:EE:05', '5' ],
);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '6', \@lag, @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('6', sub {
        my $lag_true = 1;
        my $flag = VerifyConfig->new()->validateStaticMacTable(\@lag, \@fdb, $lag_true);
        $flag += VerifyConfig->new()->validateLag(\@lag);
        return $flag;
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    return CMTestSupport::emit($self, {
        Teams => CMTestSupport::named_rows(\@lag, sub {
            my ($row) = @_;
            my $index = ($row->[0] eq 'Team10') ? 0 : 1;
            return {
                Enabled       => CMTestSupport::json_bool($row->[1]),
                Members       => $row->[2],
                FDBControlled => CMTestSupport::json_bool('true'),
                FDB           => CMTestSupport::fdb_rows($fdb[$index]),
            };
        }),
    });
}

1;
