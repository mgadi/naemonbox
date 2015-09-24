#!/usr/bin/perl -w
#
# check_all_interfaces.pl - Nagios(r) network traffic monitor plugin
# Copyright (C) 2008 Martijn Lievaart <m <at> rtij.nl>
# Based on check_iferrors.pl, copyright (C) 2004 Gerd Mueller / Netways GmbH
# based on check_traffic from Adrian Wieczorek, <ads (at) irc.pila.pl>
#
# Send us bug reports, questions and comments about this plugin.
# Latest version of this software: http://www.nagiosexchange.org
#
# INSTALLATION:
# Make sure CACHE_DIR exists and is writable by the nagios user.
#
# BUGS:
# You cannot use multiple instances of this check on the same device.
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
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307

use strict;
use warnings;

# Path to cache files
use constant CACHE_DIR => "/var/cache/nagios/iferrors";

use Net::SNMP;
use Getopt::Long;
&Getopt::Long::config('bundling');

use constant VERSION => "0.1";

# SNMP OIDs for Errors
use constant snmpIfInErrors    => '1.3.6.1.2.1.2.2.1.14';
use constant snmpIfOutErrors   => '1.3.6.1.2.1.2.2.1.20';
use constant snmpIfDescr       => '1.3.6.1.2.1.2.2.1.2';

# exit values
use constant STATUS_OK       => 0;
use constant STATUS_WARNING  => 1;
use constant STATUS_CRITICAL => 2;
use constant STATUS_UNKNOWN  => 3;

my @STATUS = ('OK', 'WARNING', 'CRITICAL', 'UNKNOWN');

#$| = 1;
#use Data::Dumper;

# default values;
my $warn_usage = 1;
my $crit_usage = 5;
my $snmp_community  = "public";
my $host_address;
my $iface_descr;
my $opt_h;
my $port=161;
my $snmp_version = 2;

usage_and_exit() unless
    GetOptions("h|help"           => \$opt_h,
	       "C|community=s"    => \$snmp_community,
	       "w|warning=s"      => \$warn_usage,
	       "c|critical=s"     => \$crit_usage,
	       "p|port=i"         => \$port,
	       "i|interface=s"    => \$iface_descr,
	       "H|hostname=s"     => \$host_address,
	       "v|version=s"      => \$snmp_version
	       );

usage_and_exit() if $opt_h or not $host_address;

#
# Parse SNMP options and set up session.
#
my ($session, $error);

if ( $snmp_version =~ /^[12]$/ ) {
    ( $session, $error ) = Net::SNMP->session(-hostname  => $host_address,
					      -community => $snmp_community,
					      -port      => $port,
					      -version   => $snmp_version
					      );

    if ( !defined($session) ) {
	print("UNKNOWN: $error");
	exit STATUS_UNKNOWN;
    }
}
#elsif ( $snmp_version == /3/ ) {
#    print("UNKNOWN: No support for SNMP v3 yet\n");
#    exit STATUS_UNKNOWN;
#}
else {
    print("UNKNOWN: No support for SNMP v$snmp_version yet\n");
    exit STATUS_UNKNOWN;
}

#
# Get interface descriptions and current error values
#

my %iface_descr = get_iface_descr();
my %in_errors = get_errors(snmpIfInErrors);
my %out_errors = get_errors(snmpIfOutErrors);

$session->close();

#
# Get old error values, if any
#

my $last_check_time;
my %if_old_data;
my $fname = CACHE_DIR . "/${host_address}";
my $file;
if (open($file, "<", $fname)) {
    my $row = <$file>;
    if ($row) {
	chomp $row;
	$last_check_time = $row;
	while ($row = <$file>) {
	    chomp $row;
	    my ($descr, $last_in_errors, $last_out_errors) = split(/\t/, $row);
	    $if_old_data{$descr}{last_in_errors} = $last_in_errors;
	    $if_old_data{$descr}{last_out_errors} = $last_out_errors;
	}
    }
    close($file);
}

#
# Check for errors and write out new error values
#

my @error_intfs;
my ($tot_in_errors, $tot_out_errors);
my $exit_status = STATUS_OK;

my $now = time();
open($file,">", $fname) or do {
    print("UNKNOWN: Cannot open $fname for writing: $!\n");
    exit STATUS_UNKNOWN;
};

print $file "$now\n";

# The sort makes sure the interfaces are sorted in te cache file
for my $iface_number (sort { $a <=> $b} keys %iface_descr) {

    my $descr = $iface_descr{$iface_number};
    my $in_errors = $in_errors{$iface_number};
    my $out_errors = $out_errors{$iface_number};
    $last_check_time ||= $now-1;
    my $last_in_errors=$in_errors;
    my $last_out_errors=$out_errors;
    if (exists $if_old_data{$descr}) {
	$last_in_errors = $if_old_data{$descr}{last_in_errors};
	$last_out_errors = $if_old_data{$descr}{last_out_errors};
    }

    print $file "$descr\t$in_errors\t$out_errors\n";

    # counters cleared? 
    $last_in_errors = $in_errors if $last_in_errors > $in_errors;
    $last_out_errors = $out_errors if $last_out_errors > $out_errors;

#    No averages. For now we care if there are errors at all!
#    Later we can keep a running average or something like that.
#
#    In fact, this works quite good in practice, so let's leave it like this.

#    my $delta = ($now-$last_check_time);
#    my $in_avg_errors = sprintf("%.2f",($in_errors-$last_in_errors)/$delta);
#    my $out_avg_errors = sprintf("%.2f",($out_errors-$last_out_errors)/$delta));

    my $new_in_errors = $in_errors - $last_in_errors;
    $tot_in_errors += $new_in_errors;
    my $new_out_errors = $out_errors - $last_out_errors;
    $tot_out_errors += $new_out_errors;

    if ($new_in_errors > $crit_usage or $new_out_errors > $crit_usage)
    {
	$exit_status = STATUS_CRITICAL;
	push @error_intfs, $iface_number;
    }
    elsif ($new_in_errors > $warn_usage or $new_out_errors > $warn_usage)
    {
	$exit_status = STATUS_WARNING if $exit_status == STATUS_OK;
	push @error_intfs, $iface_number;
    }
}
close($file);

#
# Print the results found.
#

print($STATUS[$exit_status] . ": Total in Errors: $tot_in_errors, Total out Errors: $tot_out_errors");

#
# If errors were found, show on which interfaces in a short way
# (f.i. errors on FastEthernet 0/1 and 0/5 will be shown as
# 'FastEthernet0/1, 0/5')
#
if (@error_intfs) {

    my $intfstr = $iface_descr{shift @error_intfs};
    my $last_if = $intfstr;
    for (@error_intfs) {
	my $descr = $iface_descr{$_};
	my $short = $descr;
	# see if there is a common prefix
	my ($p1, $p2) = ($descr   =~ /(.*?)([\d\.:\/]+)$/);
	my ($q1, $q2) = ($last_if =~ /(.*?)([\d\.:\/]+)$/);
	if ($q1 eq $p1) {
	    $intfstr .= ", $p2";
	} else {
	    $intfstr .= ", $descr";
	}
	$last_if = $descr;
    }
    print "<br>Errors on $intfstr";
}
print "\n";

exit($exit_status);

#
# Subs start here....
#

sub usage_and_exit
{
    print "Check_all_interfaces.pl version " . VERSION . "\n(c) 2008 M. Lievaart\n";
    print "Usage: $0 -H host [ options ]\n\n";
    print "Options:\n";
    print " -H --host STRING or IPADDRESS\n";
    print "   Check interface on the indicated host.\n";
    print " -C --community STRING \n";
    print "   SNMP Community.\n";
    print " -i --interface STRING\n";
    print "   Regexp matching interfaces to examine, f.i. '^FastEthernet' or '^(Eth|Dot.*0\$)'.\n";
    print " -w --warning INTEGER\n";
    print "   number of necessary errors since last check to result in warning status (default: 1)\n";
    print " -c --critical INTEGER\n";
    print "   number of necessary errors since last check to result in critical status (default: 5)\n";
    print " -v --version [1 or 2]\n";
    print "   Snmp version to use, use '2' for version 2c. (default: version 2c).\n";
    
    exit STATUS_UNKNOWN;
}

#
# Read a table through snmp
#

sub get_table {
    my $oid = shift;
    my $response;
    if ( !defined($response = $session->get_table($oid) ) ) {
	my $answer = $session->error;
	printf "CRITICAL: Could not read table by SNMP: $answer\n";
	exit STATUS_CRITICAL;
    }
    return %$response;
}

#
# Get a count of errors from table $oid, return a hash indexed by interface number
#

sub get_errors {
    my $oid = shift;
    my %tmp = get_table($oid);
    my %errors;
    for (keys %tmp) {
	my $ctr = $tmp{$_};
	s/.*\.//;
	$errors{$_} = $ctr;
    }
    return %errors;
}

#
# Get a map of interfaces: ix -> description
#

sub get_iface_descr {
    my %tmp = get_table(snmpIfDescr);
    my %iface_descr;
    foreach my $key ( keys %tmp ) {
	if ( not $iface_descr or $tmp{$key} =~ /$iface_descr/ ) {
	    $key =~ /.*\.(\d+)$/;
	    $iface_descr{$1} = $tmp{$key};
	}
    }

    unless ( keys %iface_descr ) {
	printf "CRITICAL: Could not find any interfaces\n";
	exit STATUS_CRITICAL;
    }
    return %iface_descr;
}




