#! /usr/bin/perl -w

use strict;
use Getopt::Long;
use vars qw($opt_V $opt_h $opt_w $opt_c $opt_H $opt_C $opt_v $nr $dfBT $dfBU $dfBTI $dfBUI $dfMF $dfUF $dfBP $dfMP $PROGNAME);
use lib "/usr/local/nagios/libexec"  ;
use utils qw(%ERRORS &print_revision &support &usage);

$PROGNAME = "check_netapp-du";

sub print_help ();
sub print_usage ();

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}=''; 
$ENV{'ENV'}='';

Getopt::Long::Configure('bundling');
GetOptions
	("V"   => \$opt_V, "version"    => \$opt_V,
	 "h"   => \$opt_h, "help"       => \$opt_h,
	 "w=s" => \$opt_w, "warning=s"  => \$opt_w,
	 "c=s" => \$opt_c, "critical=s" => \$opt_c,
	 "H=s" => \$opt_H, "hostname=s" => \$opt_H,
	 "v=s" => \$opt_v, "volume=s" => \$opt_v,
	 "C=s" => \$opt_C, "community=s" => \$opt_C);

if ($opt_V) {
	print_revision($PROGNAME,'$Revision: 0.1 $');
	exit $ERRORS{'OK'};
}


if ($opt_h) {print_help(); exit $ERRORS{'OK'};}

($opt_H) || usage("Host name/address not specified\n");
my $host = $1 if ($opt_H =~ /([-.A-Za-z0-9]+)/);
($host) || usage("Invalid host: $opt_H\n");

($opt_v) || usage("Volume name/address not specified\n");
my $vol = $1 if ($opt_v =~ /([-.A-Za-z0-9_]+)/);
($vol) || usage("Invalid host: $opt_v\n");

($opt_w) || usage("Warning threshold not specified\n");
my $warning = $1 if ($opt_w =~ /([0-9]+)+/);
($warning) || usage("Invalid warning threshold: $opt_w\n");

($opt_c) || usage("Critical threshold not specified\n");
my $critical = $1 if ($opt_c =~ /([0-9]+)/);
($critical) || usage("Invalid critical threshold: $opt_c\n");

($opt_C) || ($opt_C = "public") ;

my $nr=0;
$nr=`/usr/bin/snmpwalk -v 2c -c $opt_C $host SNMPv2-SMI::enterprises.789.1.5.4.1.10 | /bin/grep $opt_v| /bin/grep -v snapshot | /usr/bin/awk -F' ' '{print \$1}' | /bin/awk -F. '{print \$NF}' `;
$dfBT=`/usr/bin/snmpget -v 2c -c $opt_C $host SNMPv2-SMI::enterprises.789.1.5.4.1.3.$nr`;
$dfBU=`/usr/bin/snmpget -v 2c -c $opt_C $host SNMPv2-SMI::enterprises.789.1.5.4.1.4.$nr`;

my @dfbt=split(/INTEGER:/,$dfBT);
$dfBT=$dfbt[1];
$dfBT=$dfBT/1024/1024;
$dfBTI=sprintf("%.2f", $dfBT);

my @dfbu=split(/INTEGER:/,$dfBU);
$dfBU=$dfbu[1];
$dfBU=$dfBU/1024/1024;
$dfBUI=sprintf("%.2f", $dfBU);

$dfBP=$dfBU/$dfBT*100;
$dfBP = sprintf("%.2f", $dfBP);

$dfMF=`/usr/local/groundwork/common/bin/snmpget -v 2c -c $opt_C $host SNMPv2-SMI::enterprises.789.1.5.4.1.11.$nr`;
$dfUF=`/usr/local/groundwork/common/bin/snmpget -v 2c -c $opt_C $host SNMPv2-SMI::enterprises.789.1.5.4.1.12.$nr`;

my @dfmf=split(/INTEGER:/,$dfMF);
$dfMF=$dfmf[1];
$dfMF=int($dfMF);

my @dfuf=split(/INTEGER:/,$dfUF);
$dfUF=$dfuf[1];
$dfUF=int($dfUF);

$dfMP=$dfUF/$dfMF*100;
$dfMP = sprintf("%.2f", $dfMP);

my $duWARN=$dfBTI*$opt_w/100;
my $duCRIT=$dfBTI*$opt_c/100;

if ($dfBP>$critical){ print "CRITICAL - $vol usage: $dfBUI / $dfBTI GB ($dfBP%) $dfUF/$dfMF files ($dfMP%) | DiskUsage $opt_v=$dfBUI;$duWARN;$duCRIT;0;$dfBTI\n"; exit $ERRORS{'CRITICAL'} };
if ($dfBP>$warning){ print "WARNING - $vol usage: $dfBUI / $dfBTI GB ($dfBP%) $dfUF/$dfMF files ($dfMP%) | DiskUsage $opt_v=$dfBUI;$duWARN;$duCRIT;0;$dfBTI\n"; exit $ERRORS{'WARNING'} };
print "OK - $vol usage: $dfBUI / $dfBTI GB ($dfBP%) $dfUF/$dfMF files ($dfMP%) | DiskUsage $opt_v=$dfBUI;$duWARN;$duCRIT;0;$dfBTI\n"; exit $ERRORS{'OK'};


sub print_usage () {
	print "Usage: $PROGNAME -H <host> [-C community] -w <warn> -c <crit>\n";
}

sub print_help () {
	print_revision($PROGNAME,'$Revision: 0.2 $');
	print "Copyright (c) 2009 Rob Hassing

This plugin reports the usage of a Netapp Storage volume

";
	print_usage();
	print "
-H, --hostname=HOST
   Name or IP address of host to check
-v, --volume=Volume
   Name of the volume to check
-C, --community=community
   SNMPv1 community (default public)
-w, --warning=INTEGER
   Percentage above which a WARNING status will result
-c, --critical=INTEGER
   Percentage above which a CRITICAL status will result

";
#	support();
}


