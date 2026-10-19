#!/usr/local/bin/perl

use strict;
use warnings;

package CMTestSupport;

use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

# Boolean JSON values. Plain strings stay strings so numeric attribute
# values keep the quotes the heredocs used to emit.
sub json_bool {
    my ($value) = @_;
    my $flag = (defined $value && $value eq 'true') ? 1 : 0;
    return bless { _flag => $flag }, 'CMTestSupport::Bool';
}

sub pairs {
    my @values = @_;
    my @rows;
    for (my $index = 0; $index < @values; $index += 2) {
        push @rows, [ $values[$index], $values[$index + 1] ];
    }
    return \@rows;
}

sub fdb_rows {
    my ($flat) = @_;
    my @rows;
    for (my $index = 0; $index < @{$flat}; $index += 2) {
        push @rows, [ 'MACAddress', $flat->[$index], 'VLANId', $flat->[$index + 1] ];
    }
    return \@rows;
}

sub flat_ports {
    my ($ports, $builder) = @_;
    my %mapped;
    my $slot = 0;
    for (my $index = 0; $index < @{$ports}; $index += 2) {
        my $name = $ports->[$index];
        my $enabled = $ports->[$index + 1];
        $mapped{$name} = $builder->($name, $enabled, $slot);
        $slot++;
    }
    return \%mapped;
}

sub named_rows {
    my ($rows, $builder) = @_;
    my %mapped;
    foreach my $row (@{$rows}) {
        $mapped{ $row->[0] } = $builder->($row);
    }
    return \%mapped;
}

sub build {
    my ($class, $section, $lag, $fqdn, $attr_file, $recipe) = @_;
    my $self = TestLib::new($class, $fqdn, $attr_file, $recipe, $lag);
    CMLogger->new()->logSection($section);
    return $self;
}

sub report_result {
    my ($number, $callback) = @_;
    CMLogger->new()->logSubSection('Checking Configuration');
    my $flag = $callback->();
    if ($flag == 0) {
        print "Test $number: passed\n";
    }
    else {
        print "Test $number: failed\nSee log for details\n";
    }
    return;
}

sub emit {
    my ($self, $systemd) = @_;
    my $document = {
        name     => $self->{_fqdn},
        normal   => { SystemdNetworkd => $systemd },
        run_list => [ "recipe[$self->{_recipe}]" ],
    };
    my $attr_test = _encode($document) . "\n";
    CMLogger->new()->logSubSection('Chef Attributes');
    CMLogger->new()->logLine($attr_test);
    return $attr_test;
}

sub _encode {
    my ($value) = @_;
    my $kind = ref $value;
    if ($kind eq 'CMTestSupport::Bool') {
        return $value->{_flag} ? 'true' : 'false';
    }
    if ($kind eq 'ARRAY') {
        return '[' . join(',', map { _encode($_) } @{$value}) . ']';
    }
    if ($kind eq 'HASH') {
        my @parts;
        foreach my $key (sort keys %{$value}) {
            push @parts, _encode($key) . ':' . _encode($value->{$key});
        }
        return '{' . join(',', @parts) . '}';
    }
    if (!defined $value) {
        return 'null';
    }
    my $text = $value;
    $text =~ s/\\/\\\\/g;
    $text =~ s/"/\\"/g;
    $text =~ s/\n/\\n/g;
    $text =~ s/\r/\\r/g;
    $text =~ s/\t/\\t/g;
    return '"' . $text . '"';
}

1;
