#!/usr/local/bin/perl 

package CMTest7;

use strict;
use warnings;
use lib './modules';
use TestLib;
use CMLogger;
use VerifyConfig;

our @ISA = qw(TestLib);

# Same attributes are applied to both ports #
my @ufd = ( [ "sw0p16", "true", [ "sw0p10", "sw0p20", "sw0p3" ] ],
	    [ "sw0p21", "true", [ "sw0p10", "sw0p4" ] ] );

sub new
{
	my $class = shift;
	my $fqdn = shift;
	my $attrFile = shift;
	my $recipe = shift;
	
	my $self = $class->SUPER::new( $fqdn, $attrFile, $recipe, [] );
	bless( $self, $class );
	
	CMLogger->new()->logSection( "7" );
	
	return $self;
}

sub checkConfig 
{
	my $self = shift;
	my $flag = 0;
	
	CMLogger->new()->logSubSection( "Checking Configuration" );
	$flag += VerifyConfig->new()->validateUfd( \@ufd );

	if ( $flag == 0 )
        {
                print "Test 7: passed\n";
        }
        else
        {
                print "Test 7: failed\nSee log for details\n";
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
      "UFD": {
        "$ufd[0][0]": {
          "Enabled": $ufd[0][1],
          "BindCarrier": "$ufd[0][2][0] $ufd[0][2][1] $ufd[0][2][2]"
        },
        "$ufd[1][0]": {
          "Enabled": $ufd[1][1],
          "BindCarrier": "$ufd[1][2][0] $ufd[1][2][1]"
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
