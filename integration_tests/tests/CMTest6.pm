#!/usr/local/bin/perl 

package CMTest6;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

my @lag = ( [ "Team10", "true", [ "sw0p14", "sw0p13" ] ],
            [ "Team11", "false", [ "sw0p15" ] ] );
my @fdb = ( [ "AA:BB:CC:FF:EE:02", "2", "AA:BB:CC:FF:EE:03", "3" ],
            [ "AA:BB:CC:ff:EE:04", "4", "AA:BB:CC:FF:EE:05", "5" ] );

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, \@lag );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "6" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	my $lagTrue = 1;
	
	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag = VerifyConfig->new()->validateStaticMacTable( \@lag, \@fdb, $lagTrue );
	$flag += VerifyConfig->new()->validateLag( \@lag );

	if ( $flag == 0 )
        {
                print "Test 6: passed\n";
        }
        else
        {
                print "Test 6: failed\nSee log for details\n";
        }
}

sub getAttributes 
{
	my $self = shift;
	
	CMLogger->new()->logSubSection( "Chef Attributes" );


	my $attrTest = "";

	# Variable protion of the attributes file, depending on test number #
	$attrTest = <<END;	
{
  "name": "$self->{ _fqdn }",
  "normal": {
    "SystemdNetworkd": {
      "Teams": {
        "$lag[0][0]": {
          "Enabled": $lag[0][1],
          "Members": ["$lag[0][2][0]", "$lag[0][2][1]"],
          "FDBControlled": true,
          "FDB": [
            [ "MACAddress", "$fdb[0][0]", "VLANId", "$fdb[0][1]" ],
            [ "MACAddress", "$fdb[0][2]", "VLANId", "$fdb[0][3]" ]
          ]
        },
        "$lag[1][0]": {
          "Enabled": $lag[1][1],
          "Members": ["$lag[1][2][0]"],
          "FDBControlled": true,
          "FDB": [
            [ "MACAddress", "$fdb[1][0]", "VLANId", "$fdb[1][1]" ],
            [ "MACAddress", "$fdb[1][2]", "VLANId", "$fdb[1][3]" ]
          ]
        }
      }
    }
  },
  "run_list": [
    "recipe[$self->{ _recipe }]"
  ]
}
END

	CMLogger->new()->logLine( $attrTest );
	
	# Return contents of attribute file #
	return ($attrTest);
}

1;
