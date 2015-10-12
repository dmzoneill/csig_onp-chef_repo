#!/usr/local/bin/perl 

package CMTest9;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports #
my @attrList = qw( UseL3Hash 0 UseUdp 0 LagMode 1 DscpSwpriMap 3 McastCapacity 2048 );
my $port = "sw0p0";

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, [] );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "1" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	my $lagTrue = 0;
	
	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag = VerifyConfig->new()->validateCpuAttributes( $port, \@attrList );
	
	if ( $flag == 0 ) 
	{
		print "Test 9: passed\n";
	}
	else
	{
		print "Test 9: failed\nSee log for details\n";
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
        "$port": {
          "L2HashKey": [
            [
              "$attrList[0]",
              "$attrList[1]"
            ]
          ],
	  "L3HashConfig": [
	    [
		"$attrList[2]",
		"$attrList[3]"
	    ]
	  ],
          "Attributes": [
            [
              "$attrList[4]",
              "$attrList[5]"
            ]
          ],
          "QOS": [
            [
              "$attrList[6]",
              "$attrList[7]"
            ]
	  ],
          "CpuRateLimit": [
            [
              "$attrList[8]",
              "$attrList[9]"
            ]
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
