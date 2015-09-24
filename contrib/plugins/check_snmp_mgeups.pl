#!/usr/bin/perl

#-----------------------------------------------------------------
#Copyright 2005 Ignacio Barrientos <chipi@criptonita.com>
#
#This perl script query an UM_LINK unit via SNMP and grab some
#useful information applied to determine the status of the UPS 
#to send it to Nagios.
#
#Thanks to José Beites, who gave me access to a MGE COMET S31 UPS 
#and UM-LINK unit.
#
#Thanks to check_snmp_apcups.pl
#
#This program is free software; you can redistribute it or modify
#it under the terms of the GNU General Public License
#-----------------------------------------------------------------

# READ CAREFULLY BEFORE USE THIS SCRIPT:
# 
# Please execute the script before use it with Nagios to test
# if the oid's are OK, a message will be printed if there are 
# some problems with the oid's configuration.
#
# Thank you.


use Net::SNMP;
use Getopt::Std;

$script_name = "check_snmp_mgeups";
$script_version = "0.1";

## CONNECTION STUFF ##
$ipaddress = "";		# there is not default ip address, sorry
$version = 1;			# SNMP version, old UM_LINK hw works with version 1!!.
$timeout = 2;			# SNMP query timeout
$defaultcommunity = "public";	# Default community string

$warn_batt_level = 20;		# battery level (%) that set a WARNING status.
$crit_batt_level = 10;		# battery level (%) that set a CRITICAL status.
$warn_temp = 30;		# temperature (degrees) that set a WARNING status.
$warn_overload = 70;		# output overload (%) that set WARNING status.

##################################################
##						##
##	DONT CHANGE NOTHING UNDER THIS LINE	##
##						##
##################################################

## INTERESTING DEFINES ##
my $OK = 0;
my $WARNING = 1;
my $CRITICAL = 2;

## RETURN INFO VARIABLES ##
$status = $OK;
$returnstring = "";

## OID LIST ##
$oid_ups_model = ".1.3.6.1.4.1.705.1.1.1.0";

$oid_internal_temp = ".1.3.6.1.4.1.705.1.5.7.0";			# degrees

$oid_battery_porcentage = ".1.3.6.1.4.1.705.1.5.2.0";
$oid_battery_fault = ".1.3.6.1.4.1.705.1.5.9.0";			# 1 yes, 2 no

$oid_input_outage = ".1.3.6.1.4.1.705.1.6.4.0";				# 1: ok, 2: voltage out tolerance, 3: freq out tolerance, 4: no voltage.

$oid_output_overload = ".1.3.6.1.4.1.705.1.7.2.1.4.1";			# %
$oid_output_on_bypass = ".1.3.6.1.4.1.705.1.7.3.0";                     # 1: yes, 2: no

## NOT USED ##
# $oid_battery_voltage = ".1.3.6.1.4.1.705.1.5.5.0";                      # dV
# $oid_input_voltage = ".1.3.6.1.4.1.705.1.6.2.1.2.1";                    # dV
# $oid_output_voltage = ".1.3.6.1.4.1.705.1.7.2.1.2.1";                   # dV

$oid_generic = $oid_ups_model;

## PERSONALIZED DATA VARIABLES ##
$temp = 0;

$batt_level = 0;
$batt_fault = 0;

$in_outage = 0;

$out_overload = 0;
$out_bypass = 0;

## FETCHING ARGS STUFF ##
if (@ARGV < 1) {
     print "\nERROR: Too few arguments\n";
     usage();
}

getopts("h:H:C:w:c:");

if ($opt_h)
{
	usage();
	exit(0);
}

$ipaddress = $opt_H;

if ($opt_C)
{
	$defaultcommunity = $opt_C;
}

## MAKING SNMP CONNECTION ##
my ($s, $e) = Net::SNMP->session(
     -community  =>  $defaultcommunity,
     -hostname   =>  $ipaddress,
     -version    =>  $version,
     -timeout    =>  $timeout,
);

## TESTING SNMP CONNECTION WITH A GENERIC QUERY ##
if (!defined($s->get_request($oid_generic)))
{
	$returnstring = "SNMP server not responding, host down?";
	$status = $CRITICAL;
}
else
{
	## DOING ALL WORK ##
	main();
}

## CONNECTION TO /DEV/NULL ##
$s->close();

## STUDYING THE OUTPUT ##
if ($status == $OK)
{
	$returnstring = "- No problems.";
	print "Status is OK $returnstring\n";
}
elsif ($status == $WARNING)
{
	print "Status is a WARNING level $returnstring\n";
}   
elsif ($status == $CRITICAL)
{
	print "Status is CRITICAL $returnstring\n";
}       

## GOOD BYE ## 
exit $status;

##
## getinfo: make a snmp query with OID (arg0) and put it in arg1.

sub getinfo
{
	if(!defined($s->get_request(@_[0])))
	{
		print "OID ";
		print @_[0];
		print " not exists, and can't be checked, skipping\n";
		$_[1] = undef;
		return;
	}

	foreach ($s->var_bind_names()) {
		$_[1] = $s->var_bind_list()->{$_};
	}
}

##
## main: all queries and sets

sub main
{

	## GETTING DATA ##

	getinfo($oid_internal_temp,$temp);
	getinfo($oid_battery_porcentage,$batt_level);
	getinfo($oid_battery_fault,$batt_fault);
	getinfo($oid_input_outage,$in_outage);
	getinfo($oid_output_overload,$out_overload);
	getinfo($oid_output_on_bypass,$out_bypass);
	
	## STUDYING STATUS LEVEL LOOKING SOME ISSUES ##

	## THINGS CAN CHANGE STATUS TO: WARNING ##

	if( defined($batt_level) && ($batt_level < $warn_batt_level) )
	{
		$status = $WARNING;
		$returnstring = " - Battery level is under ";
		$returnstring = "$returnstring$warn_batt_level";
		$returnstring = "$returnstring%.";
	}

	if( defined($temp) && ($temp > $warn_temp) )
	{
		$status = $WARNING;
		$returnstring = "$returnstring - Max temperature exceeded";
	}

	if( defined($out_overload) && ($out_overload > $warn_overload) )
	{
		$status = $WARNING;
		$returnstring = "$returnstring - Output overloaded";
	}

	## THINGS CAN CHANGE STATUS TO: CRITICAL ##

	if( defined($batt_level) && ($batt_level < $crit_batt_level) )
	{
		$status = $CRITICAL;
		$returnstring = " - Battery level is under ";
		$returnstring = "$returnstring$crit_batt_level";
		$returnstring = "$returnstring%.";
	}

	if( defined($batt_fault) && ($batt_fault eq 1) )
	{
		$status = $CRITICAL;
		$returnstring = "$returnstring - Battery fail";
	}

	if( defined($in_outage) && (! $in_outage eq 1) )
	{
		$status = $CRITICAL;
		$returnstring = "$returnstring - AC input fail";
	}

	if( defined($out_bypass) && ($out_bypass eq 1) )
	{
		$status = $CRITICAL;
		$returnstring = "$returnstring - System in BY PASS mode";
	}

}

##
## usage: self explaining

sub usage {
    print << "USAGE";

-----------------------------------------------------------------
$script_name v$script_version

Monitors MGE UPS via SNMP v1.

Usage: $script_name -H <hostname> [-C <community>]

Options: -H     Hostname or IP address
         -C     Community (default is public)

-----------------------------------------------------------------
Copyright 2005 Ignacio Barrientos <chipi\@criptonita.com>

Thanks to José Beites, who gave me access to a MGE COMET S31 UPS 
and UM-LINK unit.

Thanks to check_snmp_apcups.pl

This program is free software; you can redistribute it or modify
it under the terms of the GNU General Public License
-----------------------------------------------------------------

USAGE
     exit 1;
}

