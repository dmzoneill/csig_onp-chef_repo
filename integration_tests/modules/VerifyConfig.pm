#!/usr/local/bin/perl

use strict;
use warnings;

package VerifyConfig;

my $instance = undef;

sub new()
{
	my $class = shift;

	if( defined( $instance ) )
	{
		return $instance;
	}

	my $self = {};

	$instance = bless( $self , $class );

	return $instance;
}

sub validatePortState
{
	my $self = shift;
	my $ports = shift;

	my $mismatchFlag = 0;

	CMLogger->new()->logLine( "Checking port state..." );
	for ( my $j = 0; $j <= $#{ $ports }; $j += 2 )
	{
		if ( $ports->[ $j + 1 ] eq "true" )
		{
			my $setValue = `ip link show $ports->[ $j ]`;
			if ( $setValue !~ /UP/ )
			{
				$mismatchFlag = 1;
			}			
		}
		else
		{
			my $setValue = `ip link show $ports->[ $j ]`;
			if ( $setValue =~ /UP/)
			{
				$mismatchFlag = 1;
			}			
		}
	}
	
	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "Port state test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "Port state test failed!" );
	}
	
	return $mismatchFlag;
}

sub validatePortSpeed
{
	my $self = shift;
	my $speed = shift;
	my $duplex = shift;
	my $ports = shift;

	my $mismatchFlag = 0;
	$speed /= 1024;
	$duplex = ucfirst $duplex;

	CMLogger->new()->logLine( "Checking port speed..." );
	for ( my $j = 0; $j <= $#{ $ports }; $j += 2 )
	{
		if ( $ports->[ $j + 1 ] eq "true" )
		{
			my $setValue = `ethtool $ports->[ $j ]`;

			if ( $setValue !~ /Speed: ${speed}Mb/ || $setValue !~ /Duplex: ${duplex}/ )
			{
				$mismatchFlag = 1;
			}
		}
	}
	
	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "Port speed test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "Port speed test failed!" );
	}
	
	return $mismatchFlag;
}

sub validateCpuAttributes
{
	my $self = shift;
	my $port = shift;
	my $attrs = shift;

	my $mismatchFlag = 0;
	
	my @l3HashConfAttrs = qw( SipMask DipMask L4SrcMask L4DstMask DscpMask 
		IslUserMask ProtocolMask FlowMask SymmetrizeL3Fields EcmpRotation 
		Protocol1 Protocol2 UseTcp UseUdp UseProtocol1 UseProtocol2 );
	my @l2HashKeyAttrs = qw( SmacMask DmacMask EthertypeMask VlanId1Mask VlanPri1Mask
		SymmetrizeMac UseL3Hash UseL2IfIp );


	if ($port eq "sw0p0" )
	{
		for (my $i = 0; $i <= $#{ $attrs }; $i += 2 )
		{
			my $currentAttr = $attrs->[ $i ];

			foreach my $at ( @l3HashConfAttrs ) {
				if ( $at eq $currentAttr )
				{
					$currentAttr = "L3HashConfig" . $currentAttr;
				}
			}

			foreach my $at ( @l2HashKeyAttrs )
			{
				if ( $at eq $currentAttr )
                                {
                                        $currentAttr = "L2HashKey" . $currentAttr;
                                }
			}
			my $attr = lcfirst $currentAttr;
			$attr =~ s/([A-Z])/_\l$1/g;

			my $setValue = `cat /sys/class/net/$port/switch/$attr`;
			chomp( $setValue );

			if ( $setValue !~ /$attrs->[ $i + 1 ]/ )
			{
				CMLogger->new()->logLine( "$attr: fail" );
				$mismatchFlag = 1;
			}
		}
	}
	else
	{
		CMLogger->new()->logLine( "Port is not CPU port!" );
		$mismatchFlag = 1;
	}

	if ( $mismatchFlag == 0 )
	{
		CMLogger->new()->logLine( "CPU Port attribute test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "CPU Port attribute test failed!" );
	}

	return $mismatchFlag;
}

sub validatePortAttributes
{
	my $self = shift;
        my $ports = shift;
        my $attrs = shift;
	my $lagTrue = shift;

	my $mismatchFlag = 0;
	my @port_list = ();
	my @port_bool = ();

	CMLogger->new()->logLine( "Checking port attributes..." );
	if ( $lagTrue == 1 )
	{
		for ( my $j = 0; $j <= $#{ $ports }; $j++ )
		{
			$port_list[ $j ] = $ports->[ $j ][ 0 ];
                        $port_bool[ $j ] = $ports->[ $j ][ 1 ];
		}
	}
	else
	{
		for ( my $j = 0, my $i = 0; $j <= $#{ $ports }; $j += 2, $i++ )
		{
			$port_list[ $i ] = $ports->[ $j ];
			$port_bool[ $i ] = $ports->[ $j + 1 ];
		}
	}

	for ( my $j = 0; $j <= $#port_list; $j++ )
	{
		if ( $port_bool[ $j ] eq "true" )
		{
			for ( my $i = 0; $i <= $#{ $attrs }; $i += 2 )
			{
							
				my $attr = lcfirst $attrs->[ $i ];
				$attr =~ s/([A-Z])/_\l$1/g;

				my $setValue = `cat /sys/class/net/$port_list[ $j ]/switch/$attr`;
				chomp( $setValue );
				if ( $setValue =~ /^\d+$/)
				{
					if ( $setValue !~ /$attrs->[ $i + 1 ]/ )
					{
						CMLogger->new()->logLine( "$attr: fail" );
						$mismatchFlag = 1;
					}
				}
				elsif ( $setValue =~ /\n\d+ index \d+\n/)
				{
					my @setValArray = split( '\n', $setValue );
					$mismatchFlag = 1;
					foreach my $elArray (@setValArray)
					{
						if ( $elArray =~ /^(\d+) index (\d+)$/)
						{
							my $index = $2;
							my $val = $1;
							if ( $attrs->[ $i + 1 ] =~ 
								/$index $val/ )
							{
								$mismatchFlag = 0;
							}
						}
					}
					if ($mismatchFlag == 1)
					{
						print "$attrs->[ $i + 1 ]\n";
						CMLogger->new()->logLine( "$attr: fail" );
					}
				}
				else
				{
					CMLogger->new()->logLine( "Unknown format" );
					$mismatchFlag = 1;
				}
			}
		}
	}
	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "Port attributes test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "Port attributes test failed!" );
	}

	return $mismatchFlag;
}

sub validateStaticMacTable
{
	my $self = shift;
        my $ports = shift;
        my $fdb = shift;
	my $lagTrue = shift;

	my $mismatchFlag = 0;
        my @port_list = ();
        my @port_bool = ();

	CMLogger->new()->logLine( "Checking static MAC table..." );
	if ( $lagTrue == 1 )
	{
		for ( my $j = 0; $j <= $#{ $ports }; $j++ )
                {
                        $port_list[ $j ] = $ports->[ $j ][ 0 ];
                        $port_bool[ $j ] = $ports->[ $j ][ 1 ];
                }
	}
	else
	{
		for ( my $j = 0, my $i = 0; $j <= $#{ $ports }; $j += 2, $i++ )
                {
                        $port_list[ $i ] = $ports->[ $j ];
                        $port_bool[ $i ] = $ports->[ $j + 1 ];
                }
	}

	for ( my $j = 0, my $i = 0; $j <= $#{ $ports }; $j += 2, $i++ )
	{
		if ( $port_bool[ $i ] eq "true" )
		{
			for ( my $k = 0; $k <= $#{ $fdb->[ $j ] }; $k += 2 )
			{
				my $setValue = `bridge fdb show`;
				if ( $setValue !~ /$fdb->[ $j ][ $k ] dev $port_list[ $i ] vlan $fdb->[ $j ][ $k + 1 ]/i )
				{
					$mismatchFlag = 1;
				}
			}
		}
        }

	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "Static MAC table test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "Static MAC table test failed!" );
	}

	return $mismatchFlag;
}

sub validateStaticVlan
{
	my $self = shift;
        my $ports = shift;
        my $vlan = shift;
	my $lagTrue = shift;

	my $mismatchFlag = 0;
        my @port_list = ();
        my @port_bool = ();

	CMLogger->new()->logLine( "Checking static VLAN..." );
	if ( $lagTrue == 1 )
	{
		for ( my $j = 0; $j <= $#{ $ports }; $j++ )
                {
			$port_list[ $j ] = $ports->[ $j ][ 0 ];
                        $port_bool[ $j ] = $ports->[ $j ][ 1 ];
		}
	}
	else
	{
		for ( my $j = 0, my $i = 0; $j <= $#{ $ports }; $j += 2, $i++ )
                {
                        $port_list[ $i ] = $ports->[ $j ];
                        $port_bool[ $i ] = $ports->[ $j + 1 ];
                }
	} 
	

	for ( my $j = 0, my $i = 0; $j <= $#{ $ports }; $j += 2, $i++ )
	{
		if ( $port_bool[ $i ] eq "true" )
		{
			my $egress = "";
			if ( $vlan->[ $j + 1 ] eq "yes" )
			{
				$egress = "Egress Untagged";
			}

			my $setValue = `bridge vlan show`;
			if ( $setValue !~ /$port_list[ $i ]\s+$vlan->[ $j ]\s*$egress/)
			{
				$mismatchFlag = 1;
			}
		}
	}

	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "Static VLAN test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "Static VLAN test failed!" );
	}

	return $mismatchFlag;
}

sub validateLag
{
	my $self = shift;
        my $lag = shift;

	my $mismatchFlag = 0;

	CMLogger->new()->logLine( "Checking LAG..." );
	for ( my $j = 0; $j <= $#{ $lag }; $j++ )
	{
		if ( $lag->[ $j ][ 1 ] eq "true" )
		{
			for ( my $i = 0; $i <= $#{ $lag->[ $j ][ 2 ] }; $i++ )
			{
				my $setValue = `ip link show $lag->[ $j ][ 2 ][ $i ]`;

				if ( $setValue !~ /master $lag->[ $j ][ 0 ]/)
				{
					$mismatchFlag = 1;
				}
			}
		}
	}

	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "LAG test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "LAG test failed!" );
	}

	return $mismatchFlag;
}

sub validateUfd
{
	my $self = shift;
        my $ufd = shift;

	my $mismatchFlag = 0;

	CMLogger->new()->logLine( "Checking UFD..." );
	for ( my $i = 0; $i <= $#{ $ufd }; $i++ )
	{	
		my @downlinks = ();

		if ( $ufd->[ $i ][ 1 ] eq "true" )
		{
			my $setValue = `networkctl status $ufd->[ $i ][ 0 ]`;			

			for ( my $j = 0; $j <= $#{ $ufd->[ $i ][ 2 ] }; $j++ ) 
			{
				if ( $ufd->[ $i ][ 2 ][ $j ] =~ /sw0p(\d+)/ )
				{
					push @downlinks, $1;
				}
			}

			@downlinks = reverse( sort { $a <=> $b } @downlinks );

			for (my $j = 0; $j <= $#downlinks; $j++ )
			{
				if ( $downlinks[ $j ] =~ /(\d+)/ )
				{
					$downlinks[ $j ] = "sw0p" . $1;
				}
			}

			my $dl = join '\s+', @downlinks;

			if ( $setValue !~ /Carrier Bound To: $dl/ )
			{
				$mismatchFlag = 1;
				CMLogger->new()->logLine( "Failure in Uplink tests" );
			}

			for ( my $j = 0; $j <= $#downlinks; $j++ )
			{
				my $setValue = `networkctl status $downlinks[ $j ]`;
				if ( $setValue =~ /Carrier Bound By:(.*)/s )
				{
					if ($1 !~ /\s$ufd->[ $i ][ 0 ]\s/ )
					{
						$mismatchFlag = 1;
						CMLogger->new()->logLine( "Failure in Downlink tests" );
					}
				}
				else
				{
					$mismatchFlag = 1;
                                        CMLogger->new()->logLine( "Failure in Downlink tests" );
				}			
			}
		}
	}


	if ( $mismatchFlag == 0 ) 
	{
		CMLogger->new()->logLine( "UFD test passed!" );
	}
	else
	{
		CMLogger->new()->logLine( "UFD test failed!" );
	}

	return $mismatchFlag;
}

1;
