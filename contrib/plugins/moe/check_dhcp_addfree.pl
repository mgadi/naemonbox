#! /usr/bin/perl
# $Id: check_dhcp_addfree,v 1.0 2005/01/24 11:30:00 Linagora SA $
#
# This plugin is developped under GPL Licence:
# http://www.fsf.org/licenses/gpl.txt

# The Software is provided to you AS IS and WITH ALL FAULTS.
# LINAGORA makes no representation and gives no warranty whatsoever,
# whether express or implied, and without limitation, with regard to the quality,
# safety, contents, performance, merchantability, non-infringement or suitability for
# any particular or intended purpose of the Software found on the LINAGORA web site.
# In no event will LINAGORA be liable for any direct, indirect, punitive, special,
# incidental or consequential damages however they may arise and even if LINAGORA has
# been previously advised of the possibility of such damages.

#use strict;

# Changelog :
# Version 1.1 ( 03/2006 )
# - update help
# Author : Cedric TEMPLE
# 
# Version 1.0 (?):
# - First version
# Author: Raphael BORDET

use lib "/usr/lib/nagios/plugins" ;
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use vars qw($PROGNAME);
use Net::SNMP;
use Getopt::Long;
use vars qw($opt_V $opt_h $opt_v $opt_C $opt_H $opt_w $opt_c $opt_s);


$PROGNAME = $0;
sub print_help ();
sub print_usage ();

# get options
Getopt::Long::Configure('bundling');
GetOptions
    ("h"   => \$opt_h, "help"         => \$opt_h,
     "V"   => \$opt_V, "version"      => \$opt_V,
     "v=s" => \$opt_v, "snmp=s"       => \$opt_v,
     "C=s" => \$opt_C, "community=s"  => \$opt_C,
     "w=s" => \$opt_w, "warning=s"    => \$opt_w,
     "c=s" => \$opt_c, "critical=s"   => \$opt_c,
     "s=s" => \$opt_s, "subnet=s"     => \$opt_s,
     "H=s" => \$opt_H, "hostname=s"   => \$opt_H);

# version of plugin
if ($opt_V) {
    print_revision($PROGNAME,'$Revision: 1.1 $');
    exit $ERRORS{'OK'};
}

# help required
if ($opt_h) {
   print_help();
   exit $ERRORS{'OK'};
}

# MUST HAVE $opt_s
if ( ! defined($opt_s) ) {
   print_help();
   print "YOU MUST DEFINE A SUBNET WITH -s \n";
   exit $ERRORS{'WARNING'};
}

# MUST HAVE $opt_c
if ( (! defined($opt_c) ) 
    || 
  ( !defined($opt_w) ) ) {
   print_help();
   print "YOU MUST DEFINE CRITICAL AND WARNING TRESHOLD WITH -c AND -w \n";
   exit $ERRORS{'WARNING'};
}


my $WINDHCPInUse = '.1.3.6.1.4.1.311.1.3.2.1.1.2.' . $opt_s ;
my $WINDHCPFree = '.1.3.6.1.4.1.311.1.3.2.1.1.3.' . $opt_s;


# get SNMP version
($opt_v) || ($opt_v = shift) || ($opt_v = "1");
my $snmp = $1 if ($opt_v =~ /([-.A-Za-z0-9]+)/);
if ($snmp =~ /^2$/){
    $snmp = "2c";
}

# get SNMP community
($opt_C) || ($opt_C = shift) || ($opt_C = "public");
my $community = $1 if ($opt_C =~ /([-.A-Za-z0-9]+)/);


# SNMP Session
my ( $session, $error ) = Net::SNMP->session(-hostname  => $opt_H,-community => $community, -version  => $snmp);
if ( !defined($session) ) {
    print("UNKNOWN: $error");
    exit $ERRORS{'UNKNOWN'};
}


# get the DHCP in Use
my $response = undef;
my $answer; my $state;
if (!defined ($response = $session->get_request( -varbindlist => [$WINDHCPInUse] )) ) {
    $answer=$session->error;
    $session->close;
    $state = 'UNKNOWN';
    printf ("$state: SNMP error with snmp version $snmp ($answer)\n");
    $session->close;
    exit $ERRORS{$state};
}

my $addInUse = $response->{$WINDHCPInUse};

# get the DHCP Free
$response = undef;
if (!defined ($response = $session->get_request( -varbindlist => [$WINDHCPFree] )) ) {
    $answer=$session->error;
    $session->close;
    $state = 'UNKNOWN';
    printf ("$state: SNMP error with snmp version $snmp ($answer)\n");
    $session->close;
    exit $ERRORS{$state};
}

my $addFree = $response->{$WINDHCPFree};

my $perfdataOut = "DHCPInUse=".$addInUse ."add;;;; DHCPFree=".$addFree."add;" . $opt_w . ";" . $opt_c . ";0";

if ($addFree < $opt_c ) {
#    print "CRITICAL: Not enough addresses free: $addFree (< $opt_c) | $perfdataOut \n";
# résultat en français
print "OK: Adresses libres : $addFree ; Adresses utilisées: $addInUse | $perfdataOut \n";
    exit $ERRORS{'CRITICAL'};
}
if ($addFree < $opt_w ) {
#    print "WARNING: Not enough addresses free: $addFree (< $opt_w) | $perfdataOut \n";
# résultat en français
    print "WARNING: Pas assez d'adresses libres: $addFree (< $opt_w) | $perfdataOut \n";
    exit $ERRORS{'WARNING'};
}

#print "OK: Free addresses: $addFree ; Used addresses: $addInUse | $perfdataOut \n";
#Francisation du résultat
print "OK: Adresses libres : $addFree ; Adresses utilisées: $addInUse | $perfdataOut \n";

exit $ERRORS{'OK'};


sub print_usage () {
    print "\nUsage:\n";
    print "$PROGNAME : checks the number of free adresses on a Windows DHCP server with SNMP.\n";
    print "   -H (--hostname)   Hostname to query - (required)\n";
    print "   -C (--community)  SNMP read community (defaults to public,\n";
    print "                     used with SNMP v1 and v2c\n";
    print "   -v (--snmp_version)  1 for SNMP v1 (default)\n";
    print "                        2 or 2c for SNMP v2c\n";
    print "   -w (--warning)    Warning threshold : minumun of free adresses free before send a warning\n";
    print "   -c (--critical)   Critical threshold : minimu of free adresses free before send a critical\n";
    print "   -s (--subnet)     Subnet to query (example : 192.168.1\n";
    print "   -V (--version)    Plugin version\n";
    print "   -h (--help)       usage help\n";

}

sub print_help () {
    print "Copyright (c) 2005 LINAGORA SA\n";
    print "Bugs to http://www.linagora.com/\n";
    print "\n";
    print_usage();
    print "\n";
}


