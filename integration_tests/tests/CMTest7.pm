#!/usr/local/bin/perl

package CMTest7;

use strict;
use warnings;
use lib './modules';
use CMTestSupport;

our @ISA = qw(TestLib);

my @ufd = (
    [ 'sw0p16', 'true', [ 'sw0p10', 'sw0p20', 'sw0p3' ] ],
    [ 'sw0p21', 'true', [ 'sw0p10', 'sw0p4' ] ],
);

sub new {
    my $class = shift;
    return CMTestSupport::build($class, '7', [], @_);
}

sub checkConfig {
    my $self = shift;
    CMTestSupport::report_result('7', sub {
        return VerifyConfig->new()->validateUfd(\@ufd);
    });
    return;
}

sub getAttributes {
    my ($self) = @_;
    return CMTestSupport::emit($self, {
        UFD => CMTestSupport::named_rows(\@ufd, sub {
            my ($row) = @_;
            return {
                Enabled     => CMTestSupport::json_bool($row->[1]),
                BindCarrier => join(' ', @{$row->[2]}),
            };
        }),
    });
}

1;
