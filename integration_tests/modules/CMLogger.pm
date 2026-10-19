#!/usr/local/bin/perl  	

use strict;	
use warnings;	

package CMLogger;

my $instance = undef;

sub new
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


sub _write_log
{
	my $self = shift;
	my $writer = shift;

	if( !defined( $self->{ _logDescriptor } ) )
	{
		open( $self->{ _logDescriptor }, ">", $self->{ _logFilePath } );
	}

	if( defined( $self->{ _logDescriptor } ) )
	{
		$writer->( $self->{ _logDescriptor } );
	}
}

sub logLine
{
	my $self = shift;
	my $line = shift;

	$self->_write_log( sub {
		my $handle = shift;
		print $handle $line . "\n";
	} );
}

sub _log_banner
{
	my $self = shift;
	my $width = shift;
	my $label = shift;
	my $value = shift;
	my $separator = ( "=" x $width ) . "\n";
	my $line = " $label: $value\n";

	$self->_write_log( sub {
		my $handle = shift;
		print $handle $separator;
		print $handle $line;
		print $handle $separator;
	} );
}

sub logSection
{
	my $self = shift;
	my $case = shift;

	$self->_log_banner( 80, "Test Case", $case );
}

sub logSubSection
{
	my $self = shift;
	my $operation = shift;

	$self->_log_banner( 60, "Operation", $operation );
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
