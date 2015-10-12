#!/usr/local/bin/perl 

package CMTest4;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports #
my @attrList = qw(DefPri 2 BcastPruning 1);
my @ports = qw(sw0p7 true sw0p8 false);
my @vlan = qw(2 yes 3 no);

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, [] );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "4" );
	
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
	$flag += VerifyConfig->new()->validateStaticVlan( \@ports, \@vlan, $lagTrue );

        if ( $flag == 0 )
        {
                print "Test 4: passed\n";
        }
        else
        {
                print "Test 4: failed\nSee log for details\n";
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
	  "Vlans": {
	    "lab": {
	      "Id": "$vlan[0]",
	      "EgressUntagged": "$vlan[1]"
	    }
	  }
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
	  "Vlans": { 
	    "office": {
	      "Id": "$vlan[2]",
	      "EgressUntagged": "$vlan[3]"
	    }
	  }
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
