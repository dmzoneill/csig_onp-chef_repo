#!/usr/local/bin/perl 

use strict;
use warnings;
use lib './tests';
use CMTest1;
use CMTest2;
use CMTest3;
use CMTest4;
use CMTest5;
use CMTest6;
use CMTest7;
use CMTest8;
use CMTest9;

# Global vars that will be used in subroutines #
my $recipe = "systemd_networkd"; 
my $fqdn = `hostname --fqdn`;	
chomp($fqdn);
my $attrFile = "../nodes/$fqdn.json";

# Local vars - only used in main script block #
my $parseBlock = "";
my $testNum = 0;
my @testList = (1..9);
my $matchFlag = 0;


sub runTest 
{
	my $tNum = $_[0];
	
	my $module = "CMTest$tNum";
	
	my $test = $module->new( $fqdn , $attrFile , $recipe );
	$test->run();
}

sub runTests 
{
	foreach my $num (@testList) {
		runTest( $num );
	}
}

sub help
{
	$parseBlock = <<END;

	The purpose of this script is to provide a basic framework for running Chef
	integration tests in local mode for systemd. 

	The script must be executed from the directory that contains it in your Chef 
	repo directory.

	This script takes a single argument:
	    <test number>|all: this will run the test matching the given number or all tests. 

	    The following are the tests that can be run and their corresponding number:
		1) Port State + Port Attributes
		2) Port State + Port Attributes + Port Speed
		3) Port State + Port Attributes + Static MAC Table 
		4) Port State + Port Attributes + Static VLAN 
		5) Port Attributes + LAG
		6) Static MAC Table + LAG
		7) UFD
		8) Static VLAN + LAG
		9) CPU Port Attributes
	      all) All of the above
END

	print "$parseBlock\n";
}

sub main
{
	# Check that the command line argument matches a valid test number
	if(($#ARGV) == 0 && ($ARGV[0] =~ /^\d$/)) {
		$testNum = $ARGV[0];

		foreach my $num (@testList) {
			if ($num == $testNum) {
				runTest( $testNum );
			}
		}
	}
	elsif(($#ARGV) == 0 && ($ARGV[0] =~ /all/)) {
		runTests();
	}
	else
	{
		help();
	}
}

main();
