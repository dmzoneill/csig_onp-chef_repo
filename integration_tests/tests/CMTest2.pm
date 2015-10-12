#!/usr/local/bin/perl 

package CMTest2;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes / speed values are applied to all ports #
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p1 true sw0p4 false);
my $speed = 10240000;
my $duplex = "full";

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, [] );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "2" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag  = 0;
	my $lagTrue  = 0;

	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag = VerifyConfig->new()->validatePortState( \@ports );
	$flag += VerifyConfig->new()->validatePortAttributes( \@ports, \@attrList, $lagTrue );
	$flag += VerifyConfig->new()->validatePortSpeed( $speed, $duplex, \@ports );
	
	if ( $flag == 0 )
        {
                print "Test 2: passed\n";
        }
        else
        {
                print "Test 2: failed\nSee log for details\n";
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
	  "Link": {
            "Link": [
              ["BitsPerSecond","$speed"],
              ["Duplex","$duplex"]
	    ]
	  },
	  "Attributes": [
            [
              "$attrList[0]",
              "$attrList[1]"
            ],
            [
              "$attrList[2]",
              "$attrList[3]"
            ]
          ]
        },
	"$ports[2]": {
	  "Enabled": $ports[3],
          "Link": {
            "Link": [
              ["BitsPerSecond","$speed"],
              ["Duplex","$duplex"]
            ]
          },
	  "Attributes": [
            [
              "$attrList[0]",
              "$attrList[1]"
            ],
            [
              "$attrList[2]",
              "$attrList[3]"
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
