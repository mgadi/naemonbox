#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
# check_akcp.pl - checks the akcp environmental devices.
# Copyright (C) 2005  NETWAYS GmbH, www.netways.de
# Author: Marius Hein <mhein@netways.de>
# Version: $Id$
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# $Id$
# ------------------------------------------------------------------------------

# basic requirements
use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;
use Net::SNMP;

# predeclared subs
use subs qw/print_help check_value bool_state trim/;

# predeclared vars
use vars qw (
  $PROGNAME
  $VERSION

  %states
  %state_names

  $opt_host
  $opt_community
  $opt_port

  $opt_help
  $opt_man
  $opt_verbose
  $opt_version

  $max_ports
);

my $units;

my $dummy;

my $opt_warning;
my $opt_critical;

# Main values
$PROGNAME = basename($0);
$VERSION  = '1.1';

# Nagios exit states
%states = (
	OK       => 0,
	WARNING  => 1,
	CRITICAL => 2,
	UNKNOWN  => 3
);

# Nagios state names
%state_names = (
	0 => 'OK',
	1 => 'WARNING',
	2 => 'CRITICAL',
	3 => 'UNKNOWN'
);

# switchtypes
my %akcp_switchtypes = (
	1 => {
		'name'     => 'Temperature Sensor',
		'units'    => 'temp',
		'warning'  => '2:6',
		'critical' => '1:8'
	},
	2 => {
		'name'     => 'FourTo20mA Sensor',
		'units'    => 'mAmp',
		'warning'  => '15:20',
		'critical' => '10:30'
	},
	3 => {
		'name'     => 'Humidity Sensor',
		'units'    => 'humi',
		'warning'  => '-1:75',
		'critical' => '-1:80'
	},
	4 => {
		'name'     => 'Water Sensor',
		'units'    => 'water',
		'warning'  => ':3',
		'critical' => ':3'
	},
	5 => {
		'name'     => 'Atod Sensor',
		'units'    => 'atod',
		'warning'  => '15:20',
		'critical' => '10:30'
	},
	6 => {
		'name'     => 'Security Sensor',
		'units'    => 'security',
		'warning'  => ':4',
		'critical' => ':4'
	},
	8 => {
		'name'     => 'Airflow Sensor',
		'units'    => 'percent',
		'warning'  => '50:0',
		'critical' => '30:0'
	},
	10 => {
		'name'     => 'Dry Contact Sensor',
		'units'    => 'drycontact',
		'warning'  => '2:',
		'critical' => '2:'
	},
	12 => {
		'name'     => 'Voltage Sensor',
		'units'    => 'voltage',
		'warning'  => ':4',
		'critical' => ':4'
	},
	13 => {
		'name'     => 'Relay Sensor',
		'units'    => 'relay',
		'warning'  => '15:20',
		'critical' => '10:30'
	},
	14 => {
		'name'     => 'Motion Detector',
		'units'    => 'motion',
		'warning'  => ':3',
		'critical' => ':4'
	}
);

# SNMP

my $opt_community = "public";
my $snmp_version  = 1;

my @snmpoids;
my $response;
my $value;
my $oid;

# oids
my $temp_oid       = ".1.3.6.1.4.1.3854.1.2.2.1.16.1.3";
my $temp_state_oid = ".1.3.6.1.4.1.3854.1.2.2.1.16.1.4";
my $temp_units_oid = ".1.3.6.1.4.1.3854.1.2.2.1.16.1.12";

my $humi_oid       = ".1.3.6.1.4.1.3854.1.2.2.1.17.1.3";
my $humi_state_oid = ".1.3.6.1.4.1.3854.1.2.2.1.17.1.4";

my $swtt_oid      = ".1.3.6.1.4.1.3854.1.2.2.1.18.1.9";
my $swtv_oid      = ".1.3.6.1.4.1.3854.1.2.2.1.18.1.3";
my $swt_state_oid = ".1.3.6.1.4.1.3854.1.2.2.1.18.1.3";

# Get the options from cl
Getopt::Long::Configure('bundling');
GetOptions(
	'h'       => \$opt_help,
	'V'	  => \$opt_version,
	'H=s'     => \$opt_host,
	'C=s',    => \$opt_community,
	'P=n',    => \$opt_port,
	'w=s'     => \$opt_warning,
	'c=s'     => \$opt_critical,
	'man'     => \$opt_man,
	'verbose' => \$opt_verbose
  )
  || print_help( 1, 'Please check your options!' );

# If somebody wants to the help ...
if ($opt_help) {
	print_help(1);
}
elsif ($opt_version) {
	print "0.1\n"; exit 0;
}
elsif ($opt_man) {
	print_help(99);
}

# Check if all needed options present.
unless ( $opt_host && $opt_port ) {

	print_help( 1, 'Too few options!' );
}
else {

	$opt_port--;

	# Open SNMP Session
	my ( $session, $error ) = Net::SNMP->session(
		-hostname  => $opt_host,
		-community => $opt_community,
		-port      => 161,
		-version   => 1
	);

	# Session failed
	if ( !defined($session) ) {
		print $state_names{ ( $states{UNKNOWN} ) } . ": $error";
		exit $states{UNKNOWN};
	}

	# get max ports
	$max_ports = 0;
	while (1) {
		@snmpoids = ();
		push( @snmpoids, $temp_state_oid . "." . $max_ports );
		last if ( !defined( $response = $session->get_request(@snmpoids) ) );
		$max_ports++;
	}
	$max_ports--;

	# is port invalid?
	if ( $opt_port < 0 || $opt_port > $max_ports ) {
		print $state_names{ ( $states{UNKNOWN} ) } . ": Port not valid!\n";
		exit $states{UNKNOWN};
	}

	# get sensor type
	@snmpoids = ();
	push( @snmpoids, $temp_state_oid . "." . $opt_port );
	push( @snmpoids, $temp_units_oid . "." . $opt_port );
	push( @snmpoids, $humi_state_oid . "." . $opt_port );
	push( @snmpoids, $swt_state_oid . "." . $opt_port );

	if ( !defined( $response = $session->get_request(@snmpoids) ) ) {
		my $answer = $session->error;
		$session->close;

		print $state_names{ ( $states{UNKNOWN} ) } . ": SNMP error: $answer";
		exit $states{UNKNOWN};
	}

	my $myresponse   = $response;
	my $sensor_found = 0;
	my $out          = "";
	my $perfdata;
	my $state_out = -1;

	# temp sensor connected?
	if (   $myresponse->{ $temp_state_oid . "." . $opt_port } >= 2
		&& $myresponse->{ $temp_state_oid . "." . $opt_port } <= 6 )
	{
		if ( $myresponse->{ $temp_units_oid . "." . $opt_port } ) {
			$units = "C";
		}
		else {
			$units = "F";
			$akcp_switchtypes{1}{'warning'}="59:77";
			$akcp_switchtypes{1}{'critical'}="50:86";

		}
		( $state_out, $out, $perfdata ) =
		  check_sensor( $session, $opt_port, "temp", $opt_warning,
			$opt_critical, $units );
		$sensor_found = 1;
		( $dummy, $opt_warning ) = split( /,/, $opt_warning )
		  if ( defined($opt_warning) );
		( $dummy, $opt_critical ) = split( /,/, $opt_critical )
		  if ( defined($opt_critical) );

	}

	# humi sensor connected?
	if ( defined( $myresponse->{ $humi_state_oid . "." . $opt_port } ) ) {
		if (   $myresponse->{ $humi_state_oid . "." . $opt_port } >= 2
			&& $myresponse->{ $humi_state_oid . "." . $opt_port } <= 6 )
		{
			my ( $state, $myout, $myperfdata ) =
			  check_sensor( $session, $opt_port, "humi", $opt_warning,
				$opt_critical, "%" );
			$state_out = $state if ( $state > $state_out );
			$out      .= $myout;
			$perfdata .= $myperfdata;
			$sensor_found = 1;
			( $dummy, $opt_warning ) = split( /,/, $opt_warning, 2 )
			  if ( defined($opt_warning) );
			( $dummy, $opt_critical ) = split( /,/, $opt_critical, 2 )
			  if ( defined($opt_critical) );
		}
	}

	# switch type sensor connected?
	if ( defined( $myresponse->{ $swt_state_oid . "." . $opt_port } ) ) {
		if (   $myresponse->{ $swt_state_oid . "." . $opt_port } >= 2
			&& $myresponse->{ $swt_state_oid . "." . $opt_port } <= 6 )
		{
			my ( $state, $myout, $myperfdata ) =
			  check_sensor( $session, $opt_port, "switch", $opt_warning,
				$opt_critical, "" );
			$state_out = $state if ( $state > $state_out );
			$out      .= $myout;
			$perfdata .= $myperfdata;
			$sensor_found = 1;
		}
	}

	# no sensor connected!
	if ( !$sensor_found ) {
		print $state_names{ ( $states{UNKNOWN} ) } . ": No Sensor connect!\n";
		exit $states{UNKNOWN};
	}

	# plugin output
	print $state_names{ ($state_out) } . ": " . $out . "|" . $perfdata . "\n";
	exit($state_out);
}

# -------------------------
# THE SUBS:
# -------------------------

sub check_sensor {
	my $state_out;
	my $out;
	my $perfdata;
	my $value;
	my $sensor_value;
	my $sensor_min;
	my $sensor_max;
	my $sensor_hi;
	my $sensor_lo;
	my $sensor_type;

	my $type = -1;

	my ( $session, $opt_port, $opt_type, $opt_warning, $opt_critical, $units ) =
	  @_;


	@snmpoids = ();

	# get value
	if ( $opt_type =~ m/temp/i ) {
		$oid  = $temp_oid;
		$type = 1;
		push( @snmpoids, $oid . "." . $opt_port );
	}
	elsif ( $opt_type =~ m/humi/i ) {
		$oid  = $humi_oid;
		$type = -1;
		push( @snmpoids, $swtt_oid . "." . $opt_port );
		push( @snmpoids, $oid . "." . $opt_port );
	}
	else {
		$oid = $swtv_oid;
		push( @snmpoids, $swtt_oid . "." . $opt_port );
		push( @snmpoids, $oid . "." . $opt_port );
	}

	if ( !defined( $response = $session->get_request(@snmpoids) ) ) {
		my $answer = $session->error;
		$session->close;

		print $state_names{ ( $states{UNKNOWN} ) } . ": SNMP error: $answer";
		exit $states{UNKNOWN};
	}

	# get value/type
	$value = $response->{ $oid . "." . $opt_port };
	$type  = $response->{ $swtt_oid . "." . $opt_port } if ( $type == -1 );

	# set warning/cricital for switches to "normal"
	$opt_warning  = $akcp_switchtypes{$type}{'warning'} if ( !$opt_warning );
	
	$opt_critical = $akcp_switchtypes{$type}{'critical'} if ( !$opt_critical );

	# use only actual warning/critical
	($opt_warning)  = split( /,/, $opt_warning );
	($opt_critical) = split( /,/, $opt_critical );

	# get left/right of warning/critical
	my ( $opt_warning_left, $opt_warning_right ) = split( /:/, $opt_warning );
	if($opt_warning !~ m /:/  ) {
		$opt_warning_right = $opt_warning_left;
		$opt_warning_left = "";
	}
	my ( $opt_critical_left, $opt_critical_right ) =
	  split( /:/, $opt_critical );
	if($opt_critical !~ m /:/  ) {
		$opt_critical_right = $opt_critical_left;
		$opt_critical_left = "";
	}

	# test borders
	if ( check_value( $value, $opt_critical_left, $opt_critical_right ) ) {
		$state_out = $states{CRITICAL};
		$out       = "is in critical state";
	}
	elsif ( check_value( $value, $opt_warning_left, $opt_warning_right ) ) {
		$state_out = $states{WARNING};
		$out       = "is in warning state";
	}
	else {
		$state_out = $states{OK};
		$out       = "is ok";
	}

	# return output
	$out =
	  $akcp_switchtypes{$type}{'name'} . " on port " . ++$opt_port . " " . $out;
	$out .= " (" . $value . $units . ")"
	  if ( $units ne "" );
	$out .= ". ";

	# return perfdata
	$perfdata = ' ' . $akcp_switchtypes{$type}{'units'} . '=' . $value . $units;

	return ( $state_out, $out, $perfdata );
}

# check_value($value, $left, $right);

sub check_value {
	my $rw = 0;

	my ( $value, $left, $right ) = @_;

	$left  = "" if ( !$left );
	$right = "" if ( !$right );

	if ( $right ne "" && $left ne "" ) {

		# outside 
		if( $right <= $left) {
		
			$rw=1 if($value < $right || $value > $left)
		
		# inside
		} else {

			$rw=1 if($value >= $right || $value <= $left)
		}
		
	}
	elsif ( $right eq "" ) {
		$rw = 1 if ( $value <= $left );
	}
	elsif ( $left eq "" ) {
		$rw = 1 if ( $value >= $right );
	}

	return $rw;
}

# print_help($level, $msg);
# prints some message and the POD DOC
sub print_help {
	my ( $level, $msg ) = @_;
	$level = 0 unless ($level);
	pod2usage(
		{
			-message => $msg,
			-verbose => $level
		}
	);

	exit( $states{UNKNOWN} );
}

1;

__END__

=head1 NAME

check_akcp.pl - Checks the akcp environmental devies for NAGIOS.

=head1 SYNOPSIS

check_akcp.pl -h

check_akcp.pl --man

check_akcp.pl -H <host> -P <Port> [-w <warning>] [-c <critical>]

=head1 DESCRIPTION

B<check_akcp.pl> recieves the data from the akcp devices. It can check thresholds of 
the connected probes.

=head1 OPTIONS

=over 8

=item B<-h>

Display this helpmessage.

=item B<-H>

The hostname or ipaddress of the akcp device.

=item B<-C>

The snmp community of the akcp device.

=item B<-P>

The port where the probe is connected to.

=item B<-w>

The warning threshold. 

=item B<-c>

The critical threshold. 

=item B<--man>

Displays the complete perldoc manpage.

=cut

=head1 THRESHOLD FORMATS

B<1.> start <= end

The startvalue have to be less than the endvalue

B<2.> start and ':' is not required if start is infinity>

If you set a threshold of '12' it's the same like ':12'

B<3.> if range is of format "start:" and end is not specified, assume end is infinity

B<4.> alert is raised if metric is outside start and end range (inclusive of endpoints)

B<5.> if range starts is lower than end then alert is inside this range 
(inclusive of endpoints)

B<6.> if there are more than one sensor connected to the port use comma to delimit the thresholds.

=head1 VERSION

$Id$

=head1 AUTHOR

NETWAYS GmbH, 2005, http://www.netways.de.

Written by Gerd Mueller <gmueller@netways.de>.

Please report bugs through the contact of Nagios Exchange, http://www.nagiosexchange.org. 

