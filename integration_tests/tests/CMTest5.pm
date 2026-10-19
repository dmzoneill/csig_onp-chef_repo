#!/usr/local/bin/perl

package CMTest5;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes are applied to both teams.
my @attrList = qw(DefPri 2 BcastPruning 1);
my @lag = (
    [ 'Team10', 'true', [ 'sw0p10', 'sw0p9' ] ],
    [ 'Team11', 'false', [ 'sw0p12', 'sw0p11' ] ],
);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '5', \@lag, @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('5', sub {
        my $lag_true = 1;
        my $flag = VerifyConfig->new()->validatePortAttributes(\@lag, \@attrList, $lag_true);
        $flag += VerifyConfig->new()->validateLag(\@lag);
        return $flag;
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    my $attributes = CMTestSupport::pairs(@attrList);
    return CMTestSupport::emit($self, {
        Teams => CMTestSupport::named_rows(\@lag, sub {
            my ($row) = @_;
            return {
                Enabled    => CMTestSupport::json_bool($row->[1]),
                Members    => $row->[2],
                Attributes => $attributes,
            };
        }),
    });
}

1;
