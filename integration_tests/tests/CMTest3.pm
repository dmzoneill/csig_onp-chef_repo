#!/usr/local/bin/perl 

package CMTest3;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports #
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p5 true sw0p6 false);
my @fdb = ( [ "AA:BB:CC:DD:EE:02", "2", "AA:BB:CC:DD:EE:03", "3" ], 
	    [ "AA:BB:CC:DD:EE:04", "4", "AA:BB:CC:DD:EE:05", "5" ] );

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, [] );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "3" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	my $lagTrue = 0;	

	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag = VerifyConfig->new()->validatePortState( \@ports );
	$flag += VerifyConfig->new()->validatePortAttributes( \@ports, \@attrList, $lagTrue );
	$flag += VerifyConfig->new()->validateStaticMacTable( \@ports, \@fdb, $lagTrue );

	if ( $flag == 0 )
        {
                print "Test 3: passed\n";
        }
        else
        {
                print "Test 3: failed\nSee log for details\n";
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
      "Ports": {
        "$ports[0]": {
          "Enabled": $ports[1],
          "Attributes": [
            [
              "$attrList[0]",
              "$attrList[1]"
            ],
            [
              "$attrList[2]",
              "$attrList[3]"
            ]
          ],
	  "FDBControlled": "yes",
	  "FDB": [
	    [ "MACAddress", "$fdb[0][0]", "VLANId", "$fdb[0][1]" ],
	    [ "MACAddress", "$fdb[0][2]", "VLANId", "$fdb[0][3]" ]
	  ]
        },
        "$ports[2]": {
          "Enabled": $ports[3],
          "Attributes": [
            [
              "$attrList[0]",
              "$attrList[1]"
            ],
            [
              "$attrList[2]",
              "$attrList[3]"
            ]
          ],
	  "FDBControlled": "yes",
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
