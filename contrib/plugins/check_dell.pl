#!/usr/bin/perl

#####################
#
#       check_dell.pl - Nagios NRPE plugin to check Dell hardware
#
#       This plugin requires the tool omreport from Dell OpenManage
#
#      This program is distributed under the Artistic License.
#      (http://www.opensource.org/licenses/artistic-license.php)
#       Copyright 2007, Tevfik Karagulle, ITeF!x Consulting (http://itefix.no)

#########################################################

use strict;
use warnings;
use Getopt::Long;

our $VERSION = "1.4";

our $OK = 0;
our $WARNING = 1;
our $CRITICAL = 2;
our $UNKNOWN = 3;

our %status_text = (
        $OK => "OK",
        $WARNING => "WARNING",
        $CRITICAL => "CRITICAL",
        $UNKNOWN => "UNKNOWN"
);

my $chassis = 0;
my $storage = 0;
my %omstatus = ();
my $omstring = "";
my $omerr = 0;
my $omwarn = 0;
my $ompath = "/opt/dell/srvadmin/bin/omreport";
my $verbose = 0;

GetOptions (
        "chassis" => \$chassis,
        "storage" => \$storage,
        "path=s" => \$ompath,
        "verbose" => \$verbose,
        "help" => sub { PrintUsage() }
) or ExitProgram($UNKNOWN, "Usage problem");

$chassis && RunOmreportChassis ($ompath);
$storage && RunOmreportStorage ($ompath);

if (scalar (keys %omstatus))
{
        # check if the component health is Ok
        foreach my $component (sort keys %omstatus)
        {
                $omstring .= "$component:$omstatus{$component}  ";
                $omstatus{$component} eq 'ok' && next;
                $omstatus{$component} eq 'non-critical' && ++$omwarn && next;
                $omerr++;
        }
} else {
        ExitProgram($UNKNOWN, "No information available");
}

ExitProgram(($omerr) ? $CRITICAL : (($omwarn) ? $WARNING : $OK), $omstring);

#### SUBROUTINES ####

##### RunOmreportChassis ####
sub RunOmreportChassis
{
        my $ompath = shift;

        open OMOUT, "$ompath chassis -fmt ssv |" or ExitProgram($UNKNOWN, "omreport problem");

        my $found = 0;
        while (<OMOUT>)
        {
                my $line = lc $_; chomp $line;

                if ($found) {
                        my ($status, $component) = split /;/, $line;
                        last if not (defined $status and defined $component);
                        $omstatus{$component} = $status;
                        print "$component:$status\n" if $verbose;
                } else {
                        $found =  ($line =~ /severity;component/);
                }
        }
}

##### RunOmreportStorage ####
sub RunOmreportStorage
{
        my $ompath = shift;

        # Server Administrator 1.x.x support
        return if RunOmreportStorageSubCommand ("", "severity;component", 0, 1);

        # server administrator 4.x.x support
        RunOmreportStorageSubCommand ("controller", "id;status;name", 1, 2, "Controller");
        RunOmreportStorageSubCommand ("vdisk","id;status;name", 1, 2);
        RunOmreportStorageSubCommand ("enclosure","id;status;name",1, 2, "Enclosure");
        RunOmreportStorageSubCommand ("battery","id;status;name", 1, 2, "Controller");
}

##### RunOmreportStorageSubCommand ####
sub RunOmreportStorageSubCommand
{
        my ($subcommand, $foundregex, $status_index, $component_index, $prefix) = @_;

        open OMOUT, "$ompath storage $subcommand -fmt ssv |" or ExitProgram($UNKNOWN, "omreport problem");

        my $found = 0;
        while (<OMOUT>)
        {
                my $line = lc $_; chomp $line;

                $found = 0 if /^$/ or /^\;/; # restart list process if empty line or ; (because Dell makes some CR where no CR is necessary, B.ZÃ¶r)

                my @lvals = split /;/, $line;
                next if not defined ($lvals[$status_index] and $lvals[$component_index]);
                if ($found) {
                        my $status = $lvals [$status_index];
                        my $component = (($prefix) ? "$prefix "  : "") . $lvals [$component_index];

                        last if not (defined $status and defined $component);
                        $omstatus{$component} = $status;
                        print "$component:$status\n" if $verbose;
                } else {
                        $found =  ($line =~ /$foundregex/);
                }
        }

        return $found ? 1 : 0;
}

##### ExitProgram #####
sub ExitProgram
{
        my ($exitcode, $message) = @_;

        my $lcomp =
        ($chassis && $storage) ? "DELL HARDWARE" :
        ($chassis && not $storage) ? "DELL CHASSIS" :
        (not $chassis && $storage) ? "DELL STORAGE" :
        "DELL UNKNOWN";

        print "$lcomp $status_text{$exitcode} - $message";
        exit ($exitcode);
}

sub PrintUsage
{
print "
Usage:
    check_dell [--chassis] [--storage] [--path omreport path] [--verbose]
    [--help]

Options:
    --chassis
        Runs omreport chassis to get status information about server chassis

    --storage
        Runs omreport storage to get status information about storage
        components. Supports Server Administrator versions 1.6/9.x and 4.5.x
        (more detailed information by using subcommands)

    --path omreport path
        Specify the location of the omreport utility. The default is
        omreport.

    --verbose
        Prints detailed information for debugging purposes

    --help
        Produces a help message.
";
}

__END__

=head1 NAME

check_dell - Nagios NRPE plugin for Dell hardware check

=head1 SYNOPSIS

B<check_dell> [B<--chassis>] [B<--storage>] [B<--path> I<omreport path>] [B<--verbose>] [B<--help>]

=head1 DESCRIPTION

B<check_dell> is a Nagios NRPE plugin for checking Dell hardware. It uses I<omreport> utility from Dell OpenManage Server Administrator

=head1 OPTIONS

=over 4

=item B<--chassis>

Runs I<omreport chassis> to get status information about server chassis

=item B<--storage>

Runs I<omreport storage> to get status information about storage components. Supports Server Administrator versions 1.6/9.x and 4.5.x (more detailed information by using subcommands)

=item B<--path> I<omreport path>

Specify the location of the omreport utility. The default is I<omreport>.

=item B<--verbose>

Prints detailed information for debugging purposes

=item B<--help>

Produces a help message.

=back

=head1 EXAMPLES

 check_dell --chassis --storage

Runs I<omreport> for chassis and storage, and produces status output. Returns WARNING if at least one component is in I<Non-Critical> state. Returns CRITICAL if at least one component is not in I<Ok> state.

 check_dell --storage --path "c:\mytools\omreport.exe"

Runs I<c:\mytools\omreport> for storage and produces status output. Returns WARNING if at least one component is in I<Non-Critical> state. Returns CRITICAL if at least one component is not in I<Ok> state.

=head1 EXIT VALUES

 0 OK
 1 WARNING
 2 CRITICAL
 3 UNKNOWN

=head1 AUTHOR

Tevfik Karagulle L<http://www.itefix.no>

=head1 SEE ALSO

=over 4

=item Nagios web site L<http://www.nagios.org>

=item Nagios NRPE documentation L<http://nagios.sourceforge.net/docs/nrpe/NRPE.pdf>

=item omreport documentation L<https://dcse.dell.com/SelfStudy/Assoc_Server_Versions/server_9_self_study/omcli/omreport.asp>

=back

=head1 COPYRIGHT

This program is distributed under the Artistic License. L<http://www.opensource.org/licenses/artistic-license.php>

=head1 VERSION

Version 1.4, December 2007

=head1 CHANGELOG

=over 4

=item changes from 1.3

 - treat some odd omreport output starting with ';' in a correct manner (thanks to B.Zoeller)

=item changes from 1.2

 - Introducing storage support for multiple versions of Server Administrator (1.6/9.x, 4.5.x)
 - bug fix: correct status code for non-critical messages

=item changes from 1.1

 - use CRITICAL instead of ERROR
 - return WARNING for non-critical alarms

=item changes from 1.0

 - proper treatment of status for multiple commands

=back

=cut



