#!/usr/local/bin/perl

package CMTest4;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports.
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p7 true sw0p8 false);
my @vlan = qw(2 yes 3 no);
my @vlan_names = qw(lab office);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '4', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('4', sub {
        my $lag_true = 0;
        my $flag = VerifyConfig->new()->validatePortState(\@ports);
        $flag += VerifyConfig->new()->validatePortAttributes(\@ports, \@attrList, $lag_true);
        $flag += VerifyConfig->new()->validateStaticVlan(\@ports, \@vlan, $lag_true);
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
                Enabled    => CMTestSupport::json_bool($enabled),
                Attributes => $attributes,
                Vlans      => {
                    $vlan_names[$slot] => {
                        Id             => $vlan[$slot * 2],
                        EgressUntagged => $vlan[($slot * 2) + 1],
                    },
                },
            };
        }),
    });
}

1;
