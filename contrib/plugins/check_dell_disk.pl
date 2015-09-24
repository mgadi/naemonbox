#!/usr/bin/perl -w

# =-=-=-=-=
# $Id: map_raid 48 2009-05-03 16:35:07Z monachus $
#
# Script to map a Dell server and tell you what
# OIDs to use for monitoring its disk subsystem
#
# Usage:  map_raid -h <host> -c <community>
# =-=-=-=-=

use strict;
use SNMP;
use Net::SNMP;
use Getopt::Long;

use vars qw( $host $community $session @oids %mib $verbose );
use vars qw( $domain );

# Load relevant MIBs for later translation
&SNMP::loadModules( 'ArrayManager-MIB', 'StorageManagement-MIB', 'CPQIDA-MIB' );

my $result = GetOptions( "host=s" 	=> \$host,
                         "comm=s"   => \$community,
						 "verbose"	=> \$verbose,
						 "domain=s" => \$domain,
					);

&usage unless( $host and $community );

if( ! gethostbyname( $host )) {
	print( "No DNS entry for $host!\n\n" );
	&usage;
}

# Useful OIDs from Dell ArrayManagement-MIB
my $am = {
    "arrayManager.1" 		=> "1.3.6.1.4.1.674.10893.1.1.1.0",
	"virtualDiskName"		=> "1.3.6.1.4.1.674.10893.1.1.140.1.1.2",
	"arrayDiskName"			=> "1.3.6.1.4.1.674.10893.1.1.130.4.1.2",
	"arrayDiskLogicalConnectionArrayDiskName"	=> "1.3.6.1.4.1.674.10893.1.1.140.3.1.2",
	"arrayDiskLogicalConnectionVirtualDiskName" => "1.3.6.1.4.1.674.10893.1.1.140.3.1.4",
	"virtualDiskState"		=> "1.3.6.1.4.1.674.10893.1.1.140.1.1.4",
	"arrayDiskState"		=> "1.3.6.1.4.1.674.10893.1.1.130.4.1.4",
};

# Useful OIDs from Dell StorageManagement-MIB
my $sm = {
    "storageManagement.1"	=> "1.3.6.1.4.1.674.10893.1.20.1",
	"virtualDiskName"		=> "1.3.6.1.4.1.674.10893.1.20.140.1.1.2",
	"arrayDiskName"			=> "1.3.6.1.4.1.674.10893.1.20.130.4.1.2",
	"arrayDiskLogicalConnectionArrayDiskName"	=> "1.3.6.1.4.1.674.10893.1.20.140.3.1.2",
	"arrayDiskLogicalConnectionVirtualDiskName"	=> "1.3.6.1.4.1.674.10893.1.20.140.3.1.4",
	"virtualDiskState"		=> "1.3.6.1.4.1.674.10893.1.20.140.1.1.4",
	"arrayDiskState"		=> "1.3.6.1.4.1.674.10893.1.20.130.4.1.4",
};

# Useful OIDs from Compaq MIB
my $cm = {
    "cpqDaCntlrModel"			=> "1.3.6.1.4.1.232.3.2.2.1.1.2.0",
	"cpqDaLogDrvIndex"			=> "1.3.6.1.4.1.232.3.2.3.1.1.2.0.1",
	"cpqDaPhyDrvIndex"			=> "1.3.6.1.4.1.232.3.2.5.1.1.2.0",
	"cpqDaPhyDrvStatus"			=> "1.3.6.1.4.1.232.3.2.5.1.1.6.0",
	"cpqDaLogDrvCondition"		=> "1.3.6.1.4.1.232.3.2.3.1.1.11.0",
	"cpqDaLogDrvPhyDrvIDs"		=> "1.3.6.1.4.1.232.3.2.3.1.1.10.0.1",
};

$session = Net::SNMP->session(
					-hostname 	=> $host,
					-community	=> $community,
					-version	=> 1,
				);

# ArrayManager-MIB::arrayManager.1
@oids=( $am->{"arrayManager.1"} );

$session->get_request( -varbindlist	=> \@oids );
if( ! $session->error_status ) {
	print( "Identified Dell ArrayManagement-MIB\n\n" ) if( $verbose );
	&dellsub( $am, "ArrayManager-MIB" );
	exit;
}

# StorageManagement-MIB::storageManagement.1
@oids=( $sm->{"storageManagement.1"} );

$session->get_request( -varbindlist	=> \@oids );
if( ! $session->error_status ) {
	print( "Identified Dell StorageManagement-MIB\n\n" ) if( $verbose );
	&dellsub( $sm, "StorageManagement-MIB" );
	exit;
}

# Compaq MIB
@oids = ( $cm->{"cpqDaCntlrModel"} );
$session->get_request( -varbindlist	=> \@oids );
if( ! $session->error_status ) {
	print( "Identified Compaq device\n\n" ) if( $verbose );
	&cpqsub( $cm );
	exit;
}

print( "Unknown MIB - please update MIB tree and software.\n\n" );
exit 1;

sub dellsub {
	# Subroutine for Dell devices

	my ( $mib, $module ) = @_;

	my @oids = ();
	my $result;
	my $vmap;		# map of virtual disks
	my $pmap;		# map of physical disks
	my $cmap;		# logical mapping

	# Get all the virtual disks
	$result = $session->get_table( -baseoid => $mib->{"virtualDiskName"} );
	&error( $session->error ) if( $session->error );

	foreach my $oid ( $session->var_bind_names ) {
		# Create the virtual map of physical members
		my $index = $oid;
		$index =~ s/^.+\.(\d+)$/$1/;
		$vmap->{$session->var_bind_list->{$oid}} = {
			"name"		=> $session->var_bind_list->{$oid},
			"oid"	    => $mib->{"virtualDiskState"} . ".$index",
			"state"		=> "",
			"members"	=> [],
	    };
	}

	# Get all the physical disks
	$result = $session->get_table( -baseoid => $mib->{"arrayDiskName"} );
	&error( $session->error ) if( $session->error );

	foreach my $oid ( $session->var_bind_names ) {
		# Create the map of physical disk name to oid
		my $index = $oid;
		$index =~ s/^.+\.(\d+)$/$1/;
		$pmap->{$session->var_bind_list->{$oid}} = {
			"name"		=> $session->var_bind_list->{$oid},
			"oid"		=> $mib->{"arrayDiskState"} . ".$index",
			"state"		=> "",
		};
	}

	# Map physical disks to logical volumes

	# Get the disk assignments in the logical map
	$result = $session->get_table( -baseoid => $mib->{"arrayDiskLogicalConnectionArrayDiskName"} );
	&error( $session->error ) if( $session->error );

	foreach my $oid ( $session->var_bind_names ) {
		# Get the index of the drive
		my $index = $oid;
		$index =~ s/^.+\.(\d+)$/$1/;
		push( @oids, $mib->{"arrayDiskLogicalConnectionVirtualDiskName"} . "." . $index );
		$cmap->[$index] = $session->var_bind_list->{$oid};
	}

	# Use each index to get the logical assignment
	$result = $session->get_request( -varbindlist	=> \@oids );
	&error( $session->error ) if( $session->error );

	foreach my $oid ( $session->var_bind_names ) {
		my $index = $oid;
		$index =~ s/^.+\.(\d+)$/$1/;
		push( @{$vmap->{$session->var_bind_list->{$oid}}->{members}}, $pmap->{$cmap->[$index]} );
	}

	# At this point we should have a logical map which contains member
	# drives

	my $nagios = {
		"command" => "check_snmp_regex",
		"oid"   => [],
		"regex" => [],
	};

	foreach my $l ( values %{$vmap} ) {
		my $count = 1;
		print( "Name:   " . $l->{name} . "\n" ) if( $verbose );
		print( "OID:    " . $l->{oid} . "\n" ) if( $verbose );;
		push( @{$nagios->{oid}}, $module . "::" . &SNMP::translateObj( $l->{oid} ));

		# Get the state of the object
		my $command = "snmpget -v 1 -Ovq -c $community -m ALL $host " . $l->{oid};
		$l->{state} = `$command`;
		chomp( $l->{state} );
		print( "Status: " . $l->{state} . "\n" ) if( $verbose );
		push( @{$nagios->{regex}}, $l->{state} );

		foreach my $p ( @{$l->{members}} ) {
			print( "   Member " . $count++ . ":\n" ) if( $verbose );
			print( "      Name:   " . $p->{name} . "\n" ) if( $verbose );
			print( "      OID:    " . $p->{oid} . "\n" ) if( $verbose );
			push( @{$nagios->{oid}}, $module . "::" . &SNMP::translateObj( $p->{oid} ));

			# Get the state of the object
			my $command = "snmpget -v 1 -Ovq -c $community -m ALL $host " . $p->{oid};
			$p->{state} = `$command`;
			chomp( $p->{state} );
			print( "      Status: " . $p->{state} . "\n" ) if( $verbose );
			push( @{$nagios->{regex}}, $p->{state} );
		}

		# Print the Nagios command
		print( "\nNagios command: \n" ) if( $verbose );

		# Extract unique snmp statuses
		my %saw;
		my @out = grep(!$saw{$_}++, @{$nagios->{regex}});
		$nagios->{regex} = "\"" . join( "|", @out ) . "\"";

		print( "check_snmp_regex!$community!" . join( ",", @{$nagios->{oid}} ) . "!" . $nagios->{regex} . "\n" );
	}
}

sub usage {
	print( "Usage:  map_raid {-h <host>} {-c <community>} [--verbose]\n" );
	exit 1;
}

sub error {
    my $error = shift;
    print( "Error: $error\n" );
    exit 1;
}

sub cpqsub {
	# Subrouting for Compaq devices

	my $mib = shift;
}
