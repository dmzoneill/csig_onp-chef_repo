#!/usr/local/bin/perl

package CMTest3;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports.
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p5 true sw0p6 false);
my @fdb = (
    [ 'AA:BB:CC:DD:EE:02', '2', 'AA:BB:CC:DD:EE:03', '3' ],
    [ 'AA:BB:CC:DD:EE:04', '4', 'AA:BB:CC:DD:EE:05', '5' ],
);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '3', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('3', sub {
        my $lag_true = 0;
        my $flag = VerifyConfig->new()->validatePortState(\@ports);
        $flag += VerifyConfig->new()->validatePortAttributes(\@ports, \@attrList, $lag_true);
        $flag += VerifyConfig->new()->validateStaticMacTable(\@ports, \@fdb, $lag_true);
        return $flag;
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    my $attributes = CMTestSupport::pairs(@attrList);
    return CMTestSupport::emit($self, {
        Ports => CMTestSupport::flat_ports(\@ports, sub {
            my (undef, $enabled, $slot) = @_;
            return {
                Enabled       => CMTestSupport::json_bool($enabled),
                Attributes    => $attributes,
                FDBControlled => 'yes',
                FDB           => CMTestSupport::fdb_rows($fdb[$slot]),
            };
        }),
    });
}

1;
