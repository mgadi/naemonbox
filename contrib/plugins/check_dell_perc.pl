#!/usr/bin/perl
#
# Josh Yost
# written: 07.14.06
# updated: 03.20.07
# 
# THE POINT
# 	Use the output from SNMP walks to create warning/critical
# signals to Nagios w/ Dell's SNMP Array/Storage Manager information.
# 
# CAVEATS
# 	Tested using: Net-SNMP 5.2, Perl 5.8.8, Nagios 2.x
#
# NOTE: I have switched to using an absolute path for the snmpwalk
#       system call.  Please adjust '$snmpwalk' as needed for your system.
#
# NOTE:	SNMPv3 hasn't been heavily tested.  I'm simply mirroring the
#       options for snmpwalk, so I would assume it works if you have SNMP
#       configured properly.
#
# I do very little sanity checking of input.  I don't see this as
# a problem because a) only authorized users should be able to run this
# script, b) this script isn't SETUID, c) any options a user could pass to
# corrupt the syscall, they could also just run on the cmdline themselves.
#
#
# COPYRIGHT
#   Distributed freely w/ no license & w/ absolutely no warranty of any kind.
# 
# VERSIONS
# 1.0.4
# 	- fixed system status handling (i'm lazy)
# 	- fixed phys-3 (should be 'ONLINE')
# 	- added SIG alarm check
# 	- added most usable options for SNMP
# 	- switched usage to exit UNKNOWN, all status errors to UNKNOWN
# 	   (I actually read the plugin guidelines ...)
# 	- better error handling, a bit more sanity checking, etc.
# 	- added more debugging output
# 	- switched to Getopt::Long
#
# 1.0.3c
# 	- fixed a couple of typos; added -l to force output to lowercase
# 	- made BKGRND INIT. & INITIALIZING ok states; added a couple of
# 	  older, un-documented OID return values I've seen from our boxes
# 	- fixed ret value for usage
# 1.0.2
# 	- using controller & physical disk names; fixed debug output a bit
# 	- re-directing STDERR to STDOUT on syscalls
# 	- added -n to always use numbers
#
# TODO
# 	Don't use Net::SNMP - the execution time goes from around 0.050 -
# 	 0.100 sec to around .180 - .220 sec on our box, mostly due to the
# 	 loading of the Net::SNMP module (as far as I can tell).
#
# BUGS &/OR PATCHES
# 	mailto: joshyost@gmail.com

use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use lib '/usr/local/nagios/libexec';
use utils qw ( %ERRORS $TIMEOUT );

our $snmpwalk = '/usr/bin/snmpwalk';
our $vers     = '1.0.4';
our $exe      = basename $0;

sub usage{
  print "Usage: $exe [-dhlnV] -D glob|phys|log|con -T sm|am -H <host>\n",
    ' ' x length("Usage: $exe "), "[-v 1|2c|3] -C <community> | -u <user>\n",
    ' ' x length("Usage: $exe "), "[-a MD5|SHA][-A <authpass>][-x DES|AES][-X <privpass>]\n",
    ' ' x length("Usage: $exe "), "[-e <secengine>][-E <conengine][-N <context>]\n";
  print "Try '--help' for more information.\n";
  exit $ERRORS{'UNKNOWN'};
}

sub VERS{
  print "$exe\t\t$vers\n";
  exit $ERRORS{'OK'};
}

sub HELP{
  print "$exe\t\t$vers\n",
        "\n\tThis script will check your Dell hardware for problems. It\n",
	"can check the Controller State, PERC Global State, Logical Disk State,\n",
	"and Physical Disk State.\n",
	"\nPlease Note: these SNMPv3 options haven't been heavily tested, but\n",
	"since I am just mirroring snmpwalk's options, there shouldn't be any\n",
	"problems. If you have issues w/ the syscall, please let me know.\n",
	"\nOPTIONS\n",
	"  -a,--authproto MD5|SHA\n",       "     Set the SNMPv3 auth protocol (defaults to MD5)\n",
	"  -A,--authpass <arg>\n",          "     Set the SNMPv3 auth passphrase\n",
	"  -C,--community <arg>\n",         "     Set the SNMP v1|v2c community string\n",
	"  -d,--debug\n",                   "     Show debugging output\n",
	"  -D,--device glob|phys|log|con\n","     Set the device type that you want to check\n",
	"  -e,--secengine <arg>\n",         "     Set the SNMPv3 security engine ID\n",
	"  -E,--conengine <arg>\n",         "     Set the SNMPv3 context engine ID\n",
	"  -h,--help\n",                    "     Show this help information\n",
	"  -H,--host <host[:port]>\n",      "     Set the target host (& port optionally)\n",
	"  -l,--lower\n",                   "     Force output to lowercase instead of uppercase\n",
	"  -n,--numbers\n",                 "     Always show numbers for controller & physical disk names\n",
	"  -N,--context <arg>\n",           "     Set the SNMP context name\n",
	"  -T,--type am|sm\n",              "     Set the OpenManage storage type used (Array or Storage Managment)\n",
	"  -v,--snmpversion 1|2c|3\n",      "     Set the SNMP version (defaults to 1)\n",
	"  -V,--version\n",                 "     Show version information\n",
	"  -u,--username <arg>\n",          "     Set the SNMPv3 username\n",
	"  -x,--privproto DES|AES\n",       "     Set the SNMPv3 priv protocol (defaults to DES)\n",
	"  -X,--privpass <arg>\n",          "     Set the SNMPv3 privacy passphrase\n",
	"\nCAVEATS\n",
	" - This script depends on having net-snmp's snmpwalk installed.\n",
	" - It also depends on having Dell's OpenManage software and either Dell's\n",
	"    Array Manager or Storage Management installed on the target system.\n",
	" - The executable path is hard-coded to '/usr/bin/snmpwalk.' Please edit the\n",
	"    '\$snmpwalk' variable near the top of the script for your environment.\n",
	" - You may also need to change the 'use lib' path to utils.pm for your system.\n",
	"\nEXAMPLES\n",
	" \$ $exe -D glob -T sm -H host1 -C public\n",
	" \$ $exe -D phys -T am -H host2 -u MD5User -A \"My Passphrase\"\n";
  exit $ERRORS{'OK'};
}

$SIG{ALRM} = sub { print "ERROR - Global timeout exceeded\n"; exit $ERRORS{'UNKNOWN'} };

#### Variables
Getopt::Long::Configure("bundling");
my %opts;
GetOptions(\%opts, 'authproto|a=s','authpass|A=s',   'community|C=s','debug|d',
                   'device|D=s',   'secengine|e=s',  'conengine|E=s','help|h',
		   'host|H=s',     'lower|l',        'numbers|n',    'context|N=s',
		   'type|T=s',     'snmpversion|v=s','version|V',    'username|u=s',
		   'privproto|x=s','privpass|X=s') || &usage();

&HELP()  if defined($opts{help});
&VERS()  if defined($opts{version});

my $aproto   = ($opts{authproto} || 'MD5');
my $aphrase  =  $opts{authpass}  if defined ($opts{authpass});
my $pass     =  $opts{community} if defined ($opts{community});
my $DEBUG    = defined ($opts{debug});
my $dev      =  $opts{device}    if defined ($opts{device});
my $sengine  =  $opts{secengine} if defined ($opts{secengine});
my $cengine  =  $opts{conengine} if defined ($opts{conengine});
my $host     =  $opts{host}      if defined ($opts{host});
my $lower    = defined ($opts{lower});
my $numbers  = defined ($opts{numbers});
my $context  =  $opts{context}   if defined ($opts{context});
my $type     =  $opts{type}      if defined ($opts{type});
my $snmpvers = ($opts{snmpversion} || '1');
my $user     =  $opts{username}  if defined ($opts{username});
my $pproto   = ($opts{privproto} || 'DES');
my $pphrase  =  $opts{privpass}  if defined ($opts{privpass});

my ($num,$exit,$id,$timeout) = (0,$ERRORS{'OK'},1,$TIMEOUT+5);
my ($out,$oid);

#### sanity checks - flesh out input errors
if (!(defined($host) && defined($type) && defined($dev) && (defined($pass) || defined($user)))){
  print "ERROR - must define -D, -H, -T, and either -C or -u.\n";
  &usage();
}
if (! -x $snmpwalk){
  print "ERROR - $snmpwalk not found. Please edit the script for your environment.\n";
  exit $ERRORS{'UNKNOWN'};
}
&usage() if !($type eq 'sm'  || $type eq 'am');
&usage() if !($dev eq 'phys' || $dev eq 'log' || $dev eq 'con' || $dev eq 'glob');
&usage() if !(($aproto eq 'MD5' || $aproto eq 'SHA') && ($pproto eq 'DES' || $pproto eq 'AES'));
&usage() if !($snmpvers eq '1' || $snmpvers eq '2c' || $snmpvers eq '3');
&usage() if (@ARGV);

if (defined($user)) { $snmpvers = '3' }

#### initialize SNMP output hash
my @names;
# log-50 was seen on OpenManage 2.1
# phys-44, con-43 was seen on OpenManage 1.8
my %perc = ('log-0'  => 'UNKNOWN',        'phys-0'  => 'UNKNOWN',    'con-0'  => 'UNKNOWN',
            'log-1'  => 'READY',          'phys-1'  => 'READY',      'con-1'  => 'READY',
	    'log-2'  => 'FAILED',         'phys-2'  => 'FAILED',     'con-2'  => 'FAILED',
	    'log-3'  => 'ONLINE',         'phys-3'  => 'ONLINE',     'con-3'  => 'ONLINE',
	    'log-4'  => 'OFFLINE',        'phys-4'  => 'OFFLINE',    'con-4'  => 'OFFLINE',
	    'log-6'  => 'DEGRADED',       'phys-6'  => 'DEGRADED',   'con-6'  => 'DEGRADED',
	    'log-7'  => 'VERIFYING',      'phys-7'  => 'RECOVERING', 'con-43' => 'UNKNOWN',
	    'log-15' => 'RESYNCHING',     'phys-11' => 'REMOVED',    'glob-1' => 'CRITICAL',
	    'log-24' => 'REBUILDING',     'phys-15' => 'RESYNCHING', 'glob-2' => 'WARNING',
	    'log-26' => 'FORMATTING',     'phys-24' => 'REBUILDING', 'glob-3' => 'NORMAL',
	    'log-32' => 'RECONSTRUCTING', 'phys-25' => 'NO MEDIA',   'glob-4' => 'UNKNOWN',
	    'log-35' => 'INITIALIZING',   'phys-26' => 'FORMATTING',
	    'log-36' => 'BKGRND INIT.',   'phys-28' => 'DIAGNOSTICS',
            'log-50' => 'BKGRND INIT.',   'phys-35' => 'INITIALIZING',
	                                  'phys-44' => 'PRED. FAILURE');

# set oid param
$id = 20 if $type eq 'sm';

# set out and oid string
if ($dev eq 'phys'){
  $out = 'Physical Disks -';
  $oid = ".1.3.6.1.4.1.674.10893.1.${id}.130.4.1.4";
}
elsif ($dev eq 'log'){
  $out = 'Logical Disk(s) -';
  $oid = ".1.3.6.1.4.1.674.10893.1.${id}.140.1.1.4";
}
elsif ($dev eq 'con') { 
  $out = 'Controller(s) -';
  $oid = ".1.3.6.1.4.1.674.10893.1.${id}.130.1.1.5";
}
else{
  $out = 'PERC Global State -';
  $oid = ".1.3.6.1.4.1.674.10893.1.${id}.2";
}

#### Prepare System Call
my $syscall;
if ($snmpvers eq '3' && defined($user)){
  if (defined($pphrase)){
    if (!defined($aphrase)){
      print "ERROR - auth passphrase is not defined.\n";
      exit $ERRORS{'UNKNOWN'};
    }
    print "debug >> using SNMPv3 authPriv\n" if $DEBUG;
    $syscall = "$snmpwalk -v${snmpvers} -u $user -a $aproto -A \"$aphrase\" -x $pproto -X \"$pphrase\" -l authPriv";
  }
  elsif (defined($aphrase)){
    print "debug >> using SNMPv3 authNoPriv\n" if $DEBUG;
    $syscall = "$snmpwalk -v${snmpvers} -u $user -a $aproto -A \"$aphrase\" -l authNoPriv";
  }
  else{
    print "debug >> using SNMPv3 noAuthNoPriv\n" if $DEBUG;
    $syscall = "$snmpwalk -v${snmpvers} -u $user -l noAuthNoPriv";
  }
  $syscall .= " -n \"$context\"" if defined($context);
  $syscall .= " -e $sengine" if defined($sengine);
  $syscall .= " -E $cengine" if defined($cengine);
}
elsif ($snmpvers eq '1' || $snmpvers eq '2c'){
  print "debug >> using SNMPv$snmpvers\n" if $DEBUG;
  $syscall = "$snmpwalk -v${snmpvers} -c \"$pass\"";
}
else{
  print "ERROR - SNMPv3 requires at least the '-u' option.\n";
  &usage();
}

print "debug >> syscall - $syscall $host $oid 2>&1\n" if $DEBUG;

#### actual initial system call
alarm $timeout;
my @output = `$syscall $host $oid 2>&1`;
my $state  = $?;
print "debug >> exit status - $state\n" if $DEBUG;

if ($state != 0){
  print @output;
  exit $ERRORS{'UNKNOWN'};
}
else{
  # test for non-existent OID
  # SNMPv1 will return no lines, v2c & v3 return an error
  if (!@output || $output[0] =~ /No Such Object available/){
    if ($DEBUG){
      print "debug >> @output";
      print "\n" if !@output;			# for cleaner debug output
    }
    print "ERROR - OID is not available on this server (wrong -T opt?).\n";
    exit $ERRORS{'UNKNOWN'};
  }

  # grab names of devices
  if (!$numbers && ($dev eq 'phys' || $dev eq 'con')){
    chop $oid; $oid .= '2';
    print "debug >> names syscall - $syscall $host $oid 2>&1\n" if $DEBUG;

    my @tmp = `$syscall $host $oid 2>&1`;
    if ($? != 0){
      print "Error running snmpwalk on oid: $oid\n";
      exit $ERRORS{'UNKNOWN'};
    }
    for (@tmp){
      print "debug >> output - $_" if $DEBUG;
      chomp;

      my $name;
      if (/STRING: (.*)/){
        $name = $1;
        # I'm sure there's a prettier way to do this, but whatever...
        if ($name =~ /.* (\d+:\d+)/ || $name =~ /^"?(.*? .*?)[ \"]/){
          print "debug >> name   - $1\n" if $DEBUG;
          push @names,$1;
        }
        else{
          print "debug >> name   - $name\n" if $DEBUG;
          push @names,$name;
        }
      }
      else{
        print "SNMP returned unknown output: $_\n";
	exit $ERRORS{'UNKNOWN'};
      }
    }
  }

  for (@output){
    $num++;
    print "debug >> output - $_" if $DEBUG;

    my $s;			# state of device
    if (/INTEGER:\s+(\d+)/){
      $s = $1; 
      print "debug >> num    - |$s|\n" if $DEBUG;
    }
    else{
      print "SNMP returned unknown output: $_\n";
      exit $ERRORS{'UNKNOWN'};
    }

    my $key = "$dev-$s";
    if ($DEBUG){
      print "debug >> key    - $key\tvalue - ", 
           (defined($perc{$key})) ? $perc{$key} : 'UNDEFINED VALUE',"\n"
    }
    # handle global status separately
    if ($dev eq 'glob'){
      (defined($perc{$key})) ? ($out .= " $perc{$key}")
                             : ($out .= " UNKNOWN VALUE");
      if    (!defined($perc{$key}))     { $exit = $ERRORS{'UNKNOWN'}  }
      elsif ($perc{$key} eq 'CRITICAL') { $exit = $ERRORS{'CRITICAL'} }
      elsif ($perc{$key} eq 'WARNING')  { $exit = $ERRORS{'WARNING'}  }
      elsif ($perc{$key} ne 'NORMAL' )  { $exit = $ERRORS{'UNKNOWN'}  }
      next;
    }
  
    # handle other devices - only display state for physical disks if 
    # state is anything other than ready or online
    if (($dev eq 'phys' && (!defined($perc{$key}) || !($perc{$key} eq 'READY' || $perc{$key} eq 'ONLINE')))
         || $dev ne 'phys'){
      (defined($names[$num-1])) ? ($out .= ' ' . $names[$num-1] . ': ') 
                                : ($out .= " #$num: ");
      (defined($perc{$key}))    ? ($out .= "$perc{$key},")
                                : ($out .= 'UNKNOWN VALUE,');
    }

    # set exit status; make sure you don't downgrade status
    if (!defined($perc{$key}) || $perc{$key} eq 'UNKNOWN'){
      $exit = $ERRORS{'UNKNOWN'} if ($exit != $ERRORS{'CRITICAL'})
    }
    elsif ($perc{$key} eq 'FAILED' || $perc{$key} eq 'OFFLINE'){
      $exit = $ERRORS{'CRITICAL'}
    }
    elsif (!($perc{$key} eq 'READY' || $perc{$key} eq 'ONLINE' ||
             $perc{$key} eq 'BKGRND INIT.' || $perc{$key} eq 'INITIALIZING')){
      $exit = $ERRORS{'WARNING'} if ($exit != $ERRORS{'CRITICAL'})
    }
  }
  #### output
  # check physical disk output
  if ($dev eq 'phys' && $out eq 'Physical Disks -'){
    $out .= ' OK';
  }
  else { chop $out if $dev ne 'glob' }         # chop trailing comma
  alarm 0;
  ($lower) ? print "\L$out\n" : print $out,"\n";
  exit $exit;
}

