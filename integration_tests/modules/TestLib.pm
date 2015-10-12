#!/usr/local/bin/perl  	

use strict;	
use warnings;	

package TestLib;

sub new
{
	my $class = shift;
	
	my $self = 
	{
		_fqdn => shift,
		_attrFile => shift,
		_recipe => shift,
		_lag => shift
	};
	
	CMLogger->new()->logLine( "FQDN      : " . $self->{ _fqdn } );
	CMLogger->new()->logLine( "ATTRFile  : " . $self->{ _attrFile } );
	CMLogger->new()->logLine( "Recipe    : " . $self->{ _recipe } );

	bless( $self, $class );
	
	return $self;
}

sub getRecipe
{
	my $self = shift;
	return $self->{ _recipe };
}

sub getLag
{
        my $self = shift;
        return $self->{ _lag };
}

sub getAttrFile
{
	my $self = shift;
	return $self->{ _attrFile };
}

sub getFQDN
{
	my $self = shift;
	return $self->{ _fqdn };
}

sub runChef
{
	my $self = shift;
	my $fqdn = $self->{ _fqdn };
	my $output = `chef-client -N $fqdn -z 2>&1`;
	
	CMLogger->new()->logSubSection( "Chef Run" );	
	CMLogger->new()->logLine( "$output" );	
}

sub delConfFiles
{
	my $self = shift;
	my $confDir = "/etc/systemd/network";

	if (-d $confDir)
	{
		my $filelist = "ls $confDir ";
	
		my @netDevs = `ls /sys/class/net`;
		foreach my $netdev ( @netDevs )
		{
			chomp( $netdev );
			my $driver = `ethtool -i $netdev 2>&1 | grep driver`;

			if( $driver !~ /fm10ks/ )
			{
				$filelist = $filelist . " -I $netdev*";
			}
		}
	
		my @confFiles = `$filelist`;
		chomp( @confFiles );

		CMLogger->new()->logSubSection( "Config Cleanup" );
	
		foreach my $file ( @confFiles )
		{
			my $output = `rm -rf $confDir/$file 2>&1`;
			CMLogger->new()->logLine( "$output" );
		}
	}
}

sub stopSystemdNetworkd
{
	my $self = shift;

	CMLogger->new()->logSubSection( "Stop systemd-networkd" );
	my $output = `systemctl stop systemd-networkd.service 2>&1`;

	if( !defined( $output ) )
	{
		$output = "";
	}

	CMLogger->new()->logLine( "$output" );
}

sub deleteOldLags
{
        my $self = shift;
        my $lag = $self->{ _lag };

        CMLogger->new()->logSubSection( "Delete old LAGs" );

        for ( my $j = 0; $j <= $#{ $lag }; $j++ )
        {
                if ( $lag->[ $j ][ 1 ] eq "true" )
                {
			my $output = `ip link del $lag->[ $j ][ 0 ] 2>&1`;

                        if( !defined( $output ) )
                        {
                                $output = "";
                        }

                        CMLogger->new()->logLine( "$output" );
                }
        }
}

sub restartFm10kd
{
	my $self = shift;
	CMLogger->new()->logSubSection( "Restart fm10kd" );	
	my $output = `fm10kdr -r 2>&1`;
	
	if( !defined( $output ) )
	{
		$output = "";
	}
	
	CMLogger->new()->logLine( "$output" );	
}

sub run
{
	my $self = shift;
	
	CMLogger->new()->logSubSection( "Running Test Case" );

	# Generate the contents of the attributes file for this test version #
	my $attributesTest = $self->getAttributes();

	if( open( my $f, ">", $self->{ _attrFile } ) )
	{
		# Overwrite attributes file with new contents #
		print $f $attributesTest;

		close($f);
		
		# Obtain fresh switch state
		$self->stopSystemdNetworkd();
		$self->deleteOldLags();
		$self->delConfFiles();
		$self->restartFm10kd();

		# Run Chef client #
		$self->runChef();

		# Check that the configuration is correct #
		$self->checkConfig();
	}
	else
	{
		 print "Error opening attributes file\nExiting...\n";
	}
}

1;
