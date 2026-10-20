#!/usr/local/bin/perl

package CMTest1;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports.
my @attrList = ('DefPri', '2', 'BcastPruning', '1', 'SchedGroupStrict', '5 0');
my @ports = qw(sw0p22 true sw0p23 false);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '1', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('1', sub {
        my $lag_true = 0;
        my $flag = VerifyConfig->new()->validatePortState(\@ports);
        $flag += VerifyConfig->new()->validatePortAttributes(\@ports, \@attrList, $lag_true);
        return $flag;
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    my $attributes = CMTestSupport::pairs(@attrList[0, 1, 2, 3]);
    my $qos = CMTestSupport::pairs($attrList[4], $attrList[5]);
    return CMTestSupport::emit($self, {
        Ports => CMTestSupport::flat_ports(\@ports, sub {
            my (undef, $enabled) = @_;
            return {
                Enabled    => CMTestSupport::json_bool($enabled),
                Attributes => $attributes,
                QOS        => $qos,
            };
        }),
    });
}

1;
