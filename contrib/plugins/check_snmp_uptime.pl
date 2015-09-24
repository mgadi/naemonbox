#!/usr/bin/perl
# ============================================================================
# ============================== INFO ========================================
# ============================================================================
# Version	: 0.1
# Date		: July 16 2011
# Author	: Michiel Timmers ( michiel.timmers AT gmx.net)
# Licence 	: GPL - summary below
#
# ============================================================================
# ============================== SUMMARY =====================================
# ============================================================================
# Most Nagios checks are done every 5 minutes and a device can reboot without
# you knowing about it. This scrip can be used to check the uptime of a 
# device, it will give a critical or a warning status when the uptime is 
# bellow 15 or 30 minutes.
#
# It will use the snmpEngineTime object to check the uptime of the SNMP
# engine. It doesn't use the sysUpTime as this is a 32-bit interger and will
# rollover after 496 days. 
#
# If you are using Cisco device please be aware of bug CSCeh49492, this will
# cause the snmpEngineTime to reset when sysUpTime will rollover. You can fix
# this with an IOS upgrade.
#
# I have only tested this with various Cisco devices and a Linux machine.
#
# Check the http://exchange.nagios.org website for new versions.
# For comments, questions, problems and patches send me an 
# e-mail (michiel.timmmers AT gmx.net). 
#
# ============================================================================
# ============================== LICENCE =====================================
# ============================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# ============================================================================
# ============================== HELP ========================================
# ============================================================================
# Help : ./check_snmp_uptime.pl --help
#
# ============================================================================

use warnings;
use strict;
use Net::SNMP;
use Getopt::Long;
#use lib "/usr/local/nagios/libexec";
#use utils qw(%ERRORS $TIMEOUT);


# ============================================================================
# ============================== NAGIOS VARIABLES ============================
# ============================================================================

my $TIMEOUT 				= 15;	# This is the global script timeout, not the SNMP timeout
my %ERRORS				= ('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);
my @Nagios_state 			= ("UNKNOWN","OK","WARNING","CRITICAL"); # Nagios states coding


# ============================================================================
# ============================== OID VARIABLES ===============================
# ============================================================================

# System description 
my $snmp_uptime     	= "1.3.6.1.6.3.10.2.1.3.0"; 	# SNMP uptime


# ============================================================================
# ============================== GLOBAL VARIABLES ============================
# ============================================================================

my $Version		= '0.1';	# Version number of this script
my $o_host		= undef; 	# Hostname
my $o_community 	= undef; 	# Community
my $o_port	 	= 161; 		# Port
my $o_help		= undef; 	# Want some help ?
my $o_verb		= undef;	# Verbose mode
my $o_version		= undef;	# Print version
my $o_timeout		= undef; 	# Timeout (Default 5)
my $o_version1		= undef;	# Use SNMPv1
my $o_version2		= undef;	# Use SNMPv2c
my $o_domain		= undef;	# Use IPv6
my $o_login		= undef;	# Login for SNMPv3
my $o_passwd		= undef;	# Pass for SNMPv3
my $v3protocols		= undef;	# V3 protocol list.
my $o_authproto		= 'sha';	# Auth protocol
my $o_privproto		= 'aes';	# Priv protocol
my $o_privpass		= undef;	# priv password


# ============================================================================
# ============================== SUBROUTINES (FUNCTIONS) =====================
# ============================================================================

# Subroutine: Print version
sub p_version { 
	print "check_snmp_uptime version : $Version\n"; 
}

# Subroutine: Print Usage
sub print_usage {
    print "Usage: $0 [-v] -H <host> [-6] -C <snmp_community> [-2] | (-l login -x passwd [-X pass -L <authp>,<privp>])  [-p <port>] [-t <timeout>] [-V]\n";
}

# Subroutine: Check number
sub isnnum { # Return true if arg is not a number
	my $num = shift;
	if ( $num =~ /^(\d+\.?\d*)|(^\.\d+)$/ ) { return 0 ;}
	return 1;
}

# Subroutine: Set final status
sub set_status { # Return worst status with this order : OK, unknown, warning, critical 
	my $new_status = shift;
	my $cur_status = shift;
	if ($new_status == 1 && $cur_status != 2) {$cur_status = $new_status;}
	if ($new_status == 2) {$cur_status = $new_status;}
	if ($new_status == 3 && $cur_status == 0) {$cur_status = $new_status;}
	return $cur_status;
}

# Subroutine: Check if SNMP table could be retrieved, otherwise give error
sub check_snmp_result {
	my $snmp_table		= shift;
	my $snmp_error_mesg	= shift;

	# Check if table is defined and does not contain specified error message.
	# Had to do string compare it will not work with a status code
	if (!defined($snmp_table) && $snmp_error_mesg !~ /table is empty or does not exist/) {
		printf("ERROR: ". $snmp_error_mesg . " : UNKNOWN\n");
		exit $ERRORS{"UNKNOWN"};
	}
}

# Subroutine: Print complete help
sub help {
	print "\nSNMP uptime plugin for Nagios\nVersion: ",$Version,"\n\n";
	print_usage();
	print <<EOT;

Options:
-v, --verbose
   Print extra debugging information 
-h, --help
   Print this help message
-H, --hostname=HOST
   Hostname or IPv4/IPv6 address of host to check
-6, --use-ipv6
   Use IPv6 connection
-C, --community=COMMUNITY NAME
   Community name for the host's SNMP agent
-1, --v1
   Use SNMPv1
-2, --v2c
   Use SNMPv2c (default)
-l, --login=LOGIN ; -x, --passwd=PASSWD
   Login and auth password for SNMPv3 authentication 
   If no priv password exists, implies AuthNoPriv 
-X, --privpass=PASSWD
   Priv password for SNMPv3 (AuthPriv protocol)
-L, --protocols=<authproto>,<privproto>
   <authproto> : Authentication protocol (md5|sha : default sha)
   <privproto> : Priv protocole (des|aes : default aes) 
-P, --port=PORT
   SNMP port (Default 161)
-t, --timeout=INTEGER
   Timeout for SNMP in seconds (Default: 5)
-V, --version
   Prints version number

Notes:
- Check the http://exchange.nagios.org website for new versions.
- For questions, problems and patches send me an e-mail (michiel.timmmers AT gmx.net).

EOT
}

# Subroutine: Verbose output
sub verb { 
	my $t=shift; 
	print $t,"\n" if defined($o_verb); 
}

# Subroutine: Verbose output
sub check_options {
	Getopt::Long::Configure ("bundling");
	GetOptions(
		'v'	=> \$o_verb,		'verbose'	=> \$o_verb,
	        'h'     => \$o_help,    	'help'        	=> \$o_help,
	        'H:s'   => \$o_host,		'hostname:s'	=> \$o_host,
	        'p:i'   => \$o_port,   		'port:i'	=> \$o_port,
	        'C:s'   => \$o_community,	'community:s'	=> \$o_community,
		'l:s'	=> \$o_login,		'login:s'	=> \$o_login,
		'x:s'	=> \$o_passwd,		'passwd:s'	=> \$o_passwd,
		'X:s'	=> \$o_privpass,	'privpass:s'	=> \$o_privpass,
		'L:s'	=> \$v3protocols,	'protocols:s'	=> \$v3protocols,   
	        't:i'   => \$o_timeout,       	'timeout:i'     => \$o_timeout,
		'V'	=> \$o_version,		'version'	=> \$o_version,
		'6'     => \$o_domain,        	'use-ipv6'      => \$o_domain,
		'1'     => \$o_version1,        'v1'            => \$o_version1,
		'2'     => \$o_version2,        'v2c'           => \$o_version2
	);


	# Basic checks
	if (defined($o_timeout) && (isnnum($o_timeout) || ($o_timeout < 2) || ($o_timeout > 60))) { 
		print "Timeout must be >1 and <60 !\n";
		print_usage();
		exit $ERRORS{"UNKNOWN"};
	}
	if (!defined($o_timeout)) {
		$o_timeout=5;
	}
	if (defined ($o_help) ) {
		help();
		exit $ERRORS{"UNKNOWN"};
	}

	if (defined($o_version)) { 
		p_version(); 
		exit $ERRORS{"UNKNOWN"};
	}

	# check host and filter 
	if ( ! defined($o_host) ) {
		print_usage();
		exit $ERRORS{"UNKNOWN"};
	}

	# Check IPv6 
	if (defined ($o_domain)) {
		$o_domain="udp/ipv6";
	} else {
		$o_domain="udp/ipv4";
	}

	# Check SNMP information
	if ( !defined($o_community) && (!defined($o_login) || !defined($o_passwd)) ){ 
		print "Put SNMP login info!\n"; 
		print_usage(); 
		exit $ERRORS{"UNKNOWN"};
	}
	if ((defined($o_login) || defined($o_passwd)) && (defined($o_community) || defined($o_version2)) ){ 
		print "Can't mix SNMP v1,v2c,v3 protocols!\n"; 
		print_usage(); 
		exit $ERRORS{"UNKNOWN"};
	}

	# Check SNMPv3 information
	if (defined ($v3protocols)) {
		if (!defined($o_login)) { 
			print "Put SNMP V3 login info with protocols!\n"; 
			print_usage(); 
			exit $ERRORS{"UNKNOWN"};
		}
		my @v3proto=split(/,/,$v3protocols);
		if ((defined ($v3proto[0])) && ($v3proto[0] ne "")) {
			$o_authproto=$v3proto[0];
		}
		if (defined ($v3proto[1])) {
			$o_privproto=$v3proto[1];
		}
		if ((defined ($v3proto[1])) && (!defined($o_privpass))) {
			print "Put SNMP v3 priv login info with priv protocols!\n";
			print_usage(); 
			exit $ERRORS{"UNKNOWN"};
		}
	}
}


# ============================================================================
# ============================== MAIN ========================================
# ============================================================================

check_options();

# Check gobal timeout if SNMP screws up
if (defined($TIMEOUT)) {
	verb("Alarm at ".$TIMEOUT." + ".$o_timeout);
	alarm($TIMEOUT+$o_timeout);
} else {
	verb("no global timeout defined : ".$o_timeout." + 15");
	alarm ($o_timeout+15);
}

# Report when the script gets "stuck" in a loop or takes to long
$SIG{'ALRM'} = sub {
	print "UNKNOWN: Script timed out\n";
	exit $ERRORS{"UNKNOWN"};
};

# Connect to host
my ($session,$error);
if (defined($o_login) && defined($o_passwd)) {
	# SNMPv3 login
	verb("SNMPv3 login");
	if (!defined ($o_privpass)) {
		# SNMPv3 login (Without encryption)
		verb("SNMPv3 AuthNoPriv login : $o_login, $o_authproto");
		($session, $error) = Net::SNMP->session(
		-domain		=> $o_domain,
		-hostname	=> $o_host,
		-version	=> 3,
		-username	=> $o_login,
		-authpassword	=> $o_passwd,
		-authprotocol	=> $o_authproto,
		-timeout	=> $o_timeout
	);  
	} else {
		# SNMPv3 login (With encryption)
		verb("SNMPv3 AuthPriv login : $o_login, $o_authproto, $o_privproto");
		($session, $error) = Net::SNMP->session(
		-domain		=> $o_domain,
		-hostname	=> $o_host,
		-version	=> 3,
		-username	=> $o_login,
		-authpassword	=> $o_passwd,
		-authprotocol	=> $o_authproto,
		-privpassword	=> $o_privpass,
		-privprotocol	=> $o_privproto,
		-timeout	=> $o_timeout
		);
	}
} else {
	if ((defined ($o_version2)) || (!defined ($o_version1))) {
		# SNMPv2 login
		verb("SNMP v2c login");
		($session, $error) = Net::SNMP->session(
		-domain		=> $o_domain,
		-hostname	=> $o_host,
		-version	=> 2,
		-community	=> $o_community,
		-port		=> $o_port,
		-timeout	=> $o_timeout
		);
	} else {
		# SNMPv1 login
		verb("SNMP v1 login");
		($session, $error) = Net::SNMP->session(
		-domain		=> $o_domain,
		-hostname	=> $o_host,
		-version	=> 1,
		-community	=> $o_community,
		-port		=> $o_port,
		-timeout	=> $o_timeout
		);
	}
}

# Check if there are any problems with the session
if (!defined($session)) {
	printf("ERROR opening session: %s.\n", $error);
	exit $ERRORS{"UNKNOWN"};
}

my $exit_val=undef;

# ============================================================================
# ============================== CHECK SNMP UPTIME ===========================
# ============================================================================

# Define variables
my $output			= "";			
my $final_status		= 0;
my $result_t;
my $index;
my @temp_oid;
my $day				= 0;
my $hour			= 0;
my $minute			= 0;

# Get SNMP table(s) and check the result
@temp_oid=($snmp_uptime);
$result_t = $session->get_request( Varbindlist => \@temp_oid);	
my $uptime_seconds = $$result_t{$snmp_uptime};

# Clear the SNMP Transport Domain and any errors associated with the object.
$session->close;

if (defined($uptime_seconds)){
	if ($uptime_seconds <= 1800){
		$final_status = 1;
	}
	if ($uptime_seconds <= 900){
		$final_status = 2;
	}

	while ($uptime_seconds >= 86400){
		$day++;
		$uptime_seconds = $uptime_seconds - 86400;
	}

	while ($uptime_seconds >= 3600){
		$hour++;
		$uptime_seconds = $uptime_seconds - 3600;
	}

	while ($uptime_seconds >= 60){
		$minute++;
		$uptime_seconds = $uptime_seconds - 60;
	}

	$output = "Uptime: ".$day." days, ".$hour." hours, ".$minute." minutes, ".$uptime_seconds." seconds";
	
}else{
	$final_status = 3;
	$output = "Can't get SNMP uptime data";
}

if ($final_status == 3) {
	print $output," : UNKNOWN\n";
	exit $ERRORS{"UNKNOWN"};
}
	
if ($final_status == 2) {
	print $output," : CRITICAL\n";
	exit $ERRORS{"CRITICAL"};
}

if ($final_status == 1) {
	print $output," : WARNING\n";
	exit $ERRORS{"WARNING"};
}

print $output," : OK\n";
exit $ERRORS{"OK"};


# ============================================================================
# ============================== NO CHECK DEFINED ============================
# ============================================================================

print "Unknown check type : UNKNOWN\n";
exit $ERRORS{"UNKNOWN"};


