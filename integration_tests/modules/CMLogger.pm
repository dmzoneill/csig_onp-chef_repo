#!/usr/local/bin/perl  	

use strict;	
use warnings;	

package CMLogger;

my $instance = undef;

sub new()
{
	my $class = shift;

	my $logDir = "./logs";
	print `mkdir -p $logDir`;

	if( defined( $instance ) )
	{
		return $instance;
	}
	
	my $self = 
	{
		_logFilePath => undef,
		_logDescriptor => undef
	};
	
	$instance = bless( $self , $class );
	
	$self->{ _logFilePath } = "$logDir/output_" . $self->getTime( "time" ) . ".log";
	
	print "Log : " . $self->{ _logFilePath } . "\n";
	
	return $instance;
}


sub logLine
{
	my $self = shift;
	my $line = shift;

	if( !defined( $self->{ _logDescriptor } ) )
	{
		open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
	}

	if( defined( $self->{ _logDescriptor } ) )
	{
		my $tf = $self->{ _logDescriptor };
		print $tf $line . "\n";			
	}
}

sub logSection
{
	my $self = shift;
	my $case = shift;
	
	my $sep = "=" x 80;
	$sep .= "\n";
	
	my $line = " Test Case: $case\n";
	
	if( !defined( $self->{ _logDescriptor } ) )
	{
		open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
	}

	if( defined( $self->{ _logDescriptor } ) )
	{
		my $tf = $self->{ _logDescriptor };
		print $tf $sep;
		print $tf $line;
		print $tf $sep;		
	}
}

sub logSubSection
{
	my $self = shift;
	my $operation = shift;
	
	my $sep = "=" x 60;
	$sep .= "\n";
	
	my $line = " Operation: $operation\n";
	
	if( !defined( $self->{ _logDescriptor } ) )
	{
		open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
	}

	if( defined( $self->{ _logDescriptor } ) )
	{
		my $tf = $self->{ _logDescriptor };
		print $tf $sep;
		print $tf $line;
		print $tf $sep;		
	}
}


sub getTime
{
	my $self = shift;
	my $request = shift;
	
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
	
	$year += 1900;
	my $retVal;

	if ( $request eq "year" )
	{
		$retVal = $year;
	}
	elsif ( $request eq "time" )
	{
		$retVal = sprintf("%02d:%02d:%02d_%02d-%02d-%04d", $hour, $min, $sec, $mday, $mon+1, $year);
	}
	return $retVal;
}

1;
