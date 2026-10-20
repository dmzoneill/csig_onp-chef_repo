#!/usr/local/bin/perl

package CMTest8;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

my @vlan = qw(2 yes 3 no);
my @lag = (
    [ 'Team12', 'true', [ 'sw0p3', 'sw0p2' ] ],
);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '8', \@lag, @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('8', sub {
        my $lag_true = 1;
        my $flag = VerifyConfig->new()->validateStaticVlan(\@lag, \@vlan, $lag_true);
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
            return {
                Enabled => CMTestSupport::json_bool($row->[1]),
                Members => $row->[2],
                Vlans   => {
                    office => {
                        Id             => $vlan[0],
                        EgressUntagged => $vlan[1],
                    },
                },
            };
        }),
    });
}

1;
