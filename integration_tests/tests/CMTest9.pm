#!/usr/local/bin/perl

package CMTest9;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

# Same attributes are applied to the CPU port.
my @attrList = qw(UseL3Hash 0 UseUdp 0 LagMode 1 DscpSwpriMap 3 McastCapacity 2048);
my $port = 'sw0p0';

sub new {
    my $class = shift;
    # Historical log section label is "1", matching the previous test file.
    return CMTestSupport::build($class, '1', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('9', sub {
        return VerifyConfig->new()->validateCpuAttributes($port, \@attrList);
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    return CMTestSupport::emit($self, {
        Ports => {
            $port => {
                L2HashKey   => CMTestSupport::pairs($attrList[0], $attrList[1]),
                L3HashConfig => CMTestSupport::pairs($attrList[2], $attrList[3]),
                Attributes  => CMTestSupport::pairs($attrList[4], $attrList[5]),
                QOS         => CMTestSupport::pairs($attrList[6], $attrList[7]),
                CpuRateLimit => CMTestSupport::pairs($attrList[8], $attrList[9]),
            },
        },
    });
}

1;
