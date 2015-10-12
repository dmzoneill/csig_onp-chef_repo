#!/usr/local/bin/perl 

package CMTest5;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports #
my @attrList = qw(DefPri 2 BcastPruning 1);
my @lag = ( [ "Team10", "true", [ "sw0p10", "sw0p9" ] ],
            [ "Team11", "false", [ "sw0p12", "sw0p11" ] ] );

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, \@lag );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "5" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	my $lagTrue = 1;

	CMLogger->new()->logSubSection( "Checking Configuration" );
        $flag = VerifyConfig->new()->validatePortAttributes( \@lag, \@attrList, $lagTrue );
        $flag += VerifyConfig->new()->validateLag( \@lag );

        if ( $flag == 0 )
        {
                print "Test 5: passed\n";
        }
        else
        {
                print "Test 5: failed\nSee log for details\n";
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
        "$lag[1][0]": {
          "Enabled": $lag[1][1],
          "Members": ["$lag[1][2][0]", "$lag[1][2][1]"],
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
