#!/usr/bin/perl -w
use strict;
#
# Windows sucks, but I have to watch for updates somehow.
# 
# (c) 2008 - Chris Moody - [ chris <at> s i l i c o n h o t r o d <dot> com ]
#

#===================================#
#  Toggle this to enble debugging   #
#===================================#
my $debug="0";          # 1 = on , 0 = off

use Getopt::Long;
#============================#
# Nagios libexec declaration #
#============================#
use lib "/usr/local/nagios/libexec";
use utils qw(%ERRORS $TIMEOUT &print_revision &support);
use vars qw($PROGNAME $PORT $CRIT $WARN $opt_H $opt_P $opt_V $opt_c $opt_h $opt_p $opt_t $opt_v $opt_w);

my @processes;
my $proc;
my $winupdateproc="wuauclt.exe";

sub die_unknown ($);
sub print_usage ();
sub print_help ();
my ($snmp_port, $timeout, $response);

$PROGNAME = "check_windows_update.pl";
$PORT = 161;
$SIG{'ALRM'} = sub { die_unknown("Timeout"); };
$ENV{'PATH'}='';
$ENV{'ENV'}='';


Getopt::Long::Configure("bundling");
if (!GetOptions("V"   => \$opt_V, "version"    => \$opt_V,
                "h"   => \$opt_h, "help"       => \$opt_h,
                "v+"  => \$opt_v, "verbose+"   => \$opt_v,
                "H=s" => \$opt_H, "hostname=s" => \$opt_H,
                "P=i" => \$opt_P, "port=i"     => \$opt_P,
                "p=s" => \$opt_p, "communitystring=s" => \$opt_p,
                "t=i" => \$opt_t, "timeout=i"  => \$opt_t)) {
        print "SNMP UNKNOWN - Error processing command line options\n";
        print_usage();
        exit $ERRORS{'UNKNOWN'};
}
if ($opt_V) {
        print_revision($PROGNAME,'$Revision: 1.0 $ ');
        exit $ERRORS{'OK'};
}
if ($opt_h) {
        print_help();
        exit $ERRORS{'OK'};
}
sub die_crit ($) {
        printf "CRITICAL - %s\n", shift;
        exit $ERRORS{'CRITICAL'};
}
unless ($opt_H) {
        print "Umm... No target host specified\n";
        print_usage();
        exit $ERRORS{'UNKNOWN'};
}

sub talk_wuauclt ($$$$) {
	@processes = `/usr/bin/snmpwalk -v 2c -c $opt_p $opt_H:$snmp_port HOST-RESOURCES-MIB::hrSWRunName`;
	if ($debug eq "1"){print "\@processes = @processes\n";};
	foreach $proc (@processes){
	if ($proc =~ /$winupdateproc/){
		if ($debug eq "1"){print "Process: $winupdateproc found running.\n";};
		if ($debug eq "1"){print "UPDATES NECESSARY....\n";};
		my $error = "Windows Updates Required";
		die_crit($error);
		}
	}
	$response = "OK";
}

$snmp_port = $opt_P ? $opt_P : getservbyname("snmp", "udp");
$snmp_port = $PORT unless defined $snmp_port;
$timeout = $opt_t ? $opt_t : $TIMEOUT;
alarm($timeout);
$response = talk_wuauclt($opt_H, $snmp_port, $opt_v, $opt_p);
if ($response){
	print "Windows is up to date - $response\n";
}
exit $ERRORS{'OK'};

sub print_usage () {
        print "Usage: $PROGNAME -H host [-P port] [-t timeout] [-s password] [-v]\n";
}

sub print_help () {
        print_revision($PROGNAME, '$Revision: 1.5 $');
        print "Copyright (c) 2008 Chris Moody (w. snippets from Holger Weiss' check_pop)\n\n";
        print "Check a Windows System for the presence of windows-updates.\n\n";
        print_usage();
        print <<EOF;

 -H, --hostname=ADDRESS
    Host name or IP Address
 -P, --port=INTEGER
    Port number (default: $PORT)
 -t, --timeout=INTEGER
    Seconds before connection times out (default: $TIMEOUT)
 -p, --password=STRING
    Password for SNMP authentication (community string)
 -v, --verbose
    Show details for command-line debugging (Nagios may truncate output)

EOF
        support();
}



