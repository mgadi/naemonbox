#!/bin/bash
#
# check_vmware_datarecovery.sh
# - A nagios plugin to monitor a VMWare datarecovery instance
#
# Usage:
#  check_vmware_datarecovery.sh [<user>@]<host> [-v] [-f <logfile>] [-d <date>] <Script 1>[,...]
# 
# where
#  [<user>@]<host>	is the network address of the appliance (and a username to login)
#  -v			verbose mode
#  -d <date>		specify date to check run on (for debugging).
#  -f <logfile>		Path to logfile containing Data Recovery messages 
#			(default: /var/log/messages)
#  <Script 1>,...	Check that these scripts have been running.
# 
# Remotely executes the real check script (which is written in python) via SSH.
#
# Checks for each encountered script that it has been finished successfully at least once.
# An encountered script might be one specified at the command line or one found in the logfile.
# You must specify at least one script (Verify might be a candidate) on the command line to make
# sure the service is running.
# 
# Returns 
#  CRITICAL if some scripts did not finish successfully.
#  OK otherwise.
#
# Author: Moritz Bechler <mbechler@eenterphace.org> for Schmieder IT Solutions (http://www.schmieder.de)
# License: MIT License
#
# Copyright (c) 2010 Moritz Bechler
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

host="$1"
shift

if [ -z "${host}" ]
then
	echo "check_vmware_datarecovery.sh [<user>@]<host> [-v] [-f logfile] [-d date] <Script 1>[,...]"
	exit 3
fi


args=""

for ARG in "$@"
do
	args="$args \"${ARG}\""
done
 
ssh $host "/usr/bin/python - $args" <<"SCRIPT"
import getopt;
import sys;
import datetime;
import time;
import re;


class ScriptRuns:
	def __init__(self):
		self.complete = 0
		self.incomplete = 0
		self.unknown = 0

	def __repr__(self):
		return "{ complete: %d incomplete: %d unknown: %d }" % (self.complete,self.incomplete,self.unknown)

def usage():
	print "vdr-nagios [-v] [-f logfile] [-d date] <Script 1>[,...]"

def main():
	try:
		optlist, args = getopt.getopt(sys.argv[1:], "hvd:f:")
	except getopt.GetoptError, err:
		print str(err)
		usage()
		sys.exit(3)

	analyzeDate = None
	verbose = False
	logFilePath = "/var/log/messages"

	for opt, arg in optlist:
		if opt in ("-h", "--help"):
			usage()
			sys.exit(3)
		elif opt in ("-d", "--date"):
			analyzeDate = datetime.date(*time.strptime(arg.strip(),"%Y-%m-%d")[:3])
		elif opt in ("-v", "--verbose"):
			verbose = True
		elif opt in ("-f", "--logfile"):
			logFilePath = arg
		else:
			assert False, "Unhandled option"

	if len(args) != 1:
		usage()
		sys.exit(3)

	scripts = {}
	for script in args[0].split(","):
		scripts[script] = ScriptRuns()

	failures = []
	
	
	if not analyzeDate:
		analyzeDate = datetime.date.today()

	analyzeDateString = "(" + analyzeDate.strftime("%b") + repr(analyzeDate.day).rjust(3) + " (0\d|1[01]):|" + \
		(analyzeDate-datetime.timedelta(1)).strftime("%b") + repr((analyzeDate-datetime.timedelta(1)).day).rjust(3) + " (2\d|1[2-9]):)"


	if verbose:
		print "Analyzing " + analyzeDateString + " in File " + logFilePath

	matchDateRegex = "^" + analyzeDateString + "\d\d:\d\d [^ ]+ datarecovery: (?P<msg>.*)" 	
	matchDate = re.compile(matchDateRegex)

	matchScriptRegex = '^Script "(?P<script>[^"]+)" (?P<status>.+)$'
	matchScript = re.compile(matchScriptRegex)
	
	matchFailRegex = "^(Trouble reading files|Trouble writing to destination volume|Failed to create snapshot for (?P<volume>[^ ]+)), (?P<errmsg>.*)$"
	matchFail = re.compile(matchFailRegex)

	if verbose:
		print "Using Line Select Regex: " + matchDateRegex
		print "Using Script Regex:" + matchScriptRegex

	logFile = open(logFilePath, "r")

	for line in logFile:
		match = matchDate.match(line)
		if not match:
			continue
			
		msg = match.group('msg')

		if verbose:
			print "Extracted: " + msg

		scriptMatch = matchScript.match(msg)
		
		if scriptMatch:
			if not scriptMatch.group('script') in scripts:
				scripts[scriptMatch.group('script')] = ScriptRuns()
	
			if scriptMatch.group('status').startswith('completed'):
				scripts[scriptMatch.group('script')].complete += 1
			elif scriptMatch.group('status') == 'incomplete':
				scripts[scriptMatch.group('script')].incomplete += 1
			else:
					scripts[scriptMatch.group('script')].unknown += 1

		failMatch = matchFail.match(msg)
		
		if failMatch:
			failures.append({'vol': failMatch.group('volume'), 'errmsg': failMatch.group('errmsg')})

	logFile.close()

	unknownCount = 0
	completedOnceCount = 0
	incompleteCount = 0
	incompleteScripts = []
	
	for script,runs in scripts.iteritems():
		if runs.unknown > 0:
			unknownCount += 1
		
		if runs.complete > 0:
			completedOnceCount += 1
		else:
			incompleteScripts.append(script)
			incompleteCount += 1

	retVal = 0
	state = "OK"

	if incompleteCount > 0 or unknownCount > 0:
		retVal = 2
		state = "ERROR"
		
	print "%s - %d Scripts completed at least once, %d were never completed (%d contained unknown states) | completed=%d" % \
		(state, completedOnceCount, incompleteCount, unknownCount, completedOnceCount)

	if incompleteCount > 0:
		print "Never completed: "
		for incompleteScript in incompleteScripts:
			print incompleteScript

	for failure in failures:
		print "Volume %s failure: %s" % (failure['vol'] and failure['vol'] or 'Unknown', failure['errmsg'])


	sys.exit(retVal)

if __name__ == "__main__":
	main()

SCRIPT;

