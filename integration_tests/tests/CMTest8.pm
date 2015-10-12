#!/usr/local/bin/perl 

package CMTest8;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);
my @vlan = qw(2 yes 3 no);
my @lag = ( [ "Team12", "true", [ "sw0p3", "sw0p2" ] ] );

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, \@lag );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "8" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	my $lagTrue = 1;	

	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag = VerifyConfig->new()->validateStaticVlan( \@lag, \@vlan, $lagTrue );
	$flag += VerifyConfig->new()->validateLag( \@lag );

	if ( $flag == 0 )
        {
                print "Test 8: passed\n";
        }
        else
        {
                print "Test 8: failed\nSee log for details\n";
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
	  "Vlans": {
            "office": {
              "Id": "$vlan[0]",
              "EgressUntagged": "$vlan[1]"
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
