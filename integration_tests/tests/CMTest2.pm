#!/usr/local/bin/perl

package CMTest2;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes / speed values are applied to all ports.
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p1 true sw0p4 false);
my $speed = 10240000;
my $duplex = 'full';

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '2', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('2', sub {
        my $lag_true = 0;
        my $flag = VerifyConfig->new()->validatePortState(\@ports);
        $flag += VerifyConfig->new()->validatePortAttributes(\@ports, \@attrList, $lag_true);
        $flag += VerifyConfig->new()->validatePortSpeed($speed, $duplex, \@ports);
        return $flag;
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    my $attributes = CMTestSupport::pairs(@attrList);
    my $link = {
        Link => [
            ['BitsPerSecond', "$speed"],
            ['Duplex', $duplex],
        ],
    };
    return CMTestSupport::emit($self, {
        Ports => CMTestSupport::flat_ports(\@ports, sub {
            my (undef, $enabled) = @_;
            return {
                Enabled    => CMTestSupport::json_bool($enabled),
                Link       => $link,
                Attributes => $attributes,
            };
        }),
    });
}

1;
