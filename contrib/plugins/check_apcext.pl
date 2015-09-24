#!/usr/bin/perl
#
# check_apcext.pl - APC Extra gear monitoring plugin for Nagios
# 05.02.07 Paul Venezia
#
# v0.0.1
#
#

use Net::SNMP;
use Getopt::Std;
use Data::Dumper;
use vars qw/ %opt /;
use strict;

if ($ARGV[0] =~ /(--help|-h|help)/ || !defined$ARGV[0]) {
	&usage;
	exit 0;
}

my $opts = 'C:H:p:w:c:';
getopts ( "$opts", \%opt ) or &usage;


my $host = $opt{H};
my $comm = $opt{C};
my $param = $opt{p};
my $warn = $opt{w};
my $crit = $opt{c};

my ($oid, $fval, $unit, $outmsg);
my $retval = 0;
my %rpduamps;

my %oids = ( 
	'nbmstemp' => {
		'label' => 'Temp',
		'unit'	=> 'degF',
		'oid' 	=> '.1.3.6.1.4.1.5528.100.4.1.1.1.2.1095346743',
		'cdef'  => '($val * .18) + 32'
		},
	'nbmshum' => {
		'label' => 'Humidity',
		'unit'	=> '%',
		'oid' 	=> '.1.3.6.1.4.1.5528.100.4.1.2.1.8.1094232622'
		},
	'nbmsairflow' => {
		'label' => 'Air Flow',
		'unit'	=> 'CFM',
		'oid' 	=> '.1.3.6.1.4.1.5528.100.4.1.5.1.8.1092459120',
		'mod'	=> 'lt'
		},
	'rpduamps' => {
		'label' => 'Power Output',
		'unit'	=> 'Amps',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.',
		'cdef'  => '$val * .10'
		},
	'acscstatus' => {
		'label' => 'Status',
		'unit'	=> '',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.1.0'
		},
	'acscload' => {
		'label' => 'Cooling Load',
		'unit'	=> 'kW',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.3.0',
		'cdef'  => '$val * .10'
		},
	'acscoutput' => {
		'label' => 'Cooling output',
		'unit'	=> 'kW',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.2.0',
		'cdef'  => '$val * .10'
		},
	'acscsupair' => {
		'label' => 'Supply Air',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.8.0',
		'cdef'  => '$val * .10'
		},
	'acscretair' => {
		'label' => 'Return Air',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.10.0',
		'cdef'  => '$val * .10'
		},
	'acscairflow' => {
		'label' => 'Airflow',
		'unit'	=> 'CFM',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.4.0',
		},
	'acscracktemp' => {
		'label' => 'Rack Inlet Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.6.0',
		'cdef'  => '$val * .10'
		},
	'acsccondin' => {
		'label' => 'Cond Inlet Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.30.0',
		'cdef'  => '$val * .10'
		},
	'acsccondout' => {
		'label' => 'Cond Outlet Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.4.1.2.28.0',
		'cdef'  => '$val * .10'
		},
	'acrcstatus' => {
		'label' => 'Status',
		'unit'	=> '',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.1.0'
		},
	'acrcload' => {
		'label' => 'Cooling Load',
		'unit'	=> 'kW',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.2.0',
		'cdef'  => '$val * .10'
		},
	'acrcoutput' => {
		'label' => 'Cooling Output',
		'unit'	=> 'kW',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.3.0',
		'cdef'  => '$val * .10'
		},
	'acrcairflow' => {
		'label' => 'Airflow',
		'unit'	=> 'CFM',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.4.0'
		},
	'acrcracktemp' => {
		'label' => 'Rack Inlet Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.6.0',
		'cdef'  => '$val * .10'
		},
	'acrcsupair' => {
		'label' => 'Supply Air',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.8.0',
		'cdef'  => '$val * .10'
		},
	'acrcretair' => {
		'label' => 'Return Air',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.10.0',
		'cdef'  => '$val * .10'
		},
	'acrcfanspeed' => {
		'label' => 'Fan Speed',
		'unit'	=> '%',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.16.0',
		'cdef'	=> '$val * .10',
		},
	'acrcfluidflow' => {
		'label' => 'Fluid Flow',
		'unit'	=> 'GPM',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.21.0',
		'cdef'	=> '$val * .10',
		'mod'	=> 'lt'
		},
	'acrcflenttemp' => {
		'label' => 'Entering Fluid Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.23.0',
		'cdef'  => '$val * .10'
		},
	'acrcflrettemp' => {
		'label' => 'Returning Fluid Temp',
		'unit'	=> 'F',
		'oid' 	=> '.1.3.6.1.4.1.318.1.1.13.3.2.2.2.25.0',
		'cdef'  => '$val * .10'
		},
	);

if (!$oids{$param}) {
	print "No test parameter specified";
	exit 3;
} else {
	$oid = $oids{$param}->{oid};
}

my ($session, $error) = Net::SNMP->session(
                                           -hostname  => $host,
                                           -community => $comm,
                                           -version   => 1,
               #                                           -translate => [-octetstring => 0x0],
                                           -port      => "161"
                                         );

	
if ($param eq "rpduamps") {
#	$param = "RackPDU";
	my $i;
	for ($i=1;$i<4;$i++) {
	  my $phoid = $oid . $i;
	  my $response = $session->get_request($phoid);
	my $err = $session->error;
	if ($err){
	        $retval = 3;
		$outmsg = "UNKNOWN";
		$session->close();
		print "$outmsg - SNMP Error connecting to $host\n";
		exit $retval;		
	}
	  $rpduamps{$i} = $response->{$phoid};
	}
		$session->close;
		#$crit = ($crit * 10);
		#$warn = ($warn * 10);

	$unit = "Amps";
	foreach my $ph ( sort keys %rpduamps ) {
		my $tphase = ($rpduamps{$ph} * .1);

		if (($tphase >= $crit) && ($retval < 2)) {
			$retval = 2;
			$outmsg = "CRITICAL";
			
		} elsif (($tphase >= $warn) && ($retval < 1)) {
			$retval = 1;
			$outmsg = "WARNING";
		
		} elsif ($retval < 1) {
			$retval = 0;
			$outmsg = "OK";
		}
		
		$fval .= "Phase $ph: " . $tphase;
		#$fval .= "Phase $ph: " . ($tphase * .1);
		if ($ph lt 3) {
			$fval .= " Amps, ";
		#} else {
		#	$fval .= " ";
		}
		
	}
	
} else {
	my $response = $session->get_request($oid);

	my $err = $session->error;
	if ($err){
	        $retval = 3;
		$outmsg = "UNKNOWN";
		$session->close();
		print "$outmsg - SNMP Error connecting to $host\n";
		exit $retval;		
	}
	
	
	my $val = $response->{$oid};
	$session->close();
	
	#if ($param eq "nbtemp") {
	#	$fval = ($val * .18) + 32;
	#	$unit = "F";
	#} 
	
	#if ($param eq "nbhum") {
	#	$fval = $val;
	#	$unit = "%";
	#} 
	
if ($param eq "acscstatus" || $param eq "acrcstatus") {
	if ($val == 1) {
		$fval = "Standby";
	        $retval = 1;
		$outmsg = "WARNING";
	} elsif ($val == 2) {
		$fval = "On";
	        $retval = 0;
		$outmsg = "OK";
	}
	} else {

	if ($oids{$param}->{cdef}) {
		$fval = eval "$oids{$param}->{cdef}";
	} else {
		$fval = $val;
	}
	
	if ($fval > $crit) {
	        $retval = 2;
		$outmsg = "CRITICAL";
	} elsif ($fval > $warn) {	
	        $retval = 1;
		$outmsg = "WARNING";
	} else {
		$retval = 0;
		$outmsg = "OK";
	}
}
} 

print "$outmsg - " . $oids{$param}->{label} . " " .$fval . " " . $oids{$param}->{unit} . "\n";


exit $retval;

sub usage {

print "Usage: $0 -H <hostip> -C <community> -p <parameter> -w <warnval> -c <critval>\n";
print "\nParameters:\n";
print  "APC NetBotz 
\tnbmstemp\tNetBotz main sensor temp
\tnbmshum \tNetBotz main sensor humidity
\tnbmsairflow\tNetBotz main sensor airflow
\nAPC Metered Rack PDU
\trpduamps\tAmps on each phase
\nAPC ACSC In-Row
\tacscstatus\tSystem status (on/standby)
\tacscload\tCooling load
\tacscoutput\tCooling output
\tacscsupair\tSupply air
\tacscairflow\tAir flow
\tacscracktemp\tRack inlet temp
\tacsccondin\tCondenser input temp
\tacsccondout\tCondenser outlet temp 
\nAPC ACRC In-Row
\tacrcstatus\tSystem status (on/standby)
\tacrcload\tCooling load
\tacrcoutput\tCooling output
\tacrcairflow\tAir flow
\tacrcracktemp\tRack inlet temp
\tacrcsupair\tSupply air
\tacrcretair\tReturn air
\tacrcfanspeed\tFan speed
\tacrcfluidflow\tFluid flow
\tacrcflenttemp\tFluid entering temp
\tacrcflrettemp\tFluid return temp\n";

}

