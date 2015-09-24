#!/usr/bin/env python

# Check IP address free for windows DHCP server
# This plugin require pysnmp
#
# Version 0.1
# Version 0.2
#	Adding a test to see if PySNMP is present.
#
# http://www.opensource.org/licenses/gpl-2.0.php
#
# Copyright (c) PREVOST Benjamin   prevost.benjamin@free.fr

import getopt, sys

try:
   from pysnmp import asn1, v1, v2c, role
except:
   print '\nPySNMP is required for this plugin.'
   print 'Check http://pysnmp.sourceforge.net/ or use your packet manager\n'
   sys.exit(3)

port = 161
addr = '0.0.0.0'
vers = '2c'
comm = 'public'
warn = 10
crit = 5
netip = '0.0.0.0'
msgerr = []
err = 0

def help():
   print "check_dhcp_free v0.1\n"
   print "\t-H\tHostname to query"
   print "\t-p\tPort to query (defaults : 161)"
   print "\t-v\tSNMP version (defaults : 2c)"
   print "\t-C\tSNMP read community (defaults to public)"
   print "\t-c\tThree critical tresholds (defaults : 10)"
   print "\t-w\tThree warning tresholds (defaults : 5)"
   print "\t-n\tNetwork ip address"
   print "\t-h\tUsage help\n"

if len(sys.argv[1:]) == 0:
   help()
   sys.exit(3)

try:
   opts, args = getopt.getopt(sys.argv[1:], "hH:p:v:C:c:w:n:")
except getopt.GetoptError:
   help()
   sys.exit(3)

opt=[o for o, a in opts]
arg=[a for o, a in opts]

if '-h' in opt:
   help()
   sys.exit(0)
if '-H' in opt:
   addr = arg[opt.index('-H')]
else:
   err = 1
   msgerr.append('Hostname or ip address is missing! The -H option is mandatory ;)')
if '-p' in opt:
   addr = arg[opt.index('-p')]
if '-v' in opt:
   vers = arg[opt.index('-v')]
if '-C' in opt:
   comm = arg[opt.index('-C')]
if '-c' in opt:
   crit = arg[opt.index('-c')]
if '-w' in opt:
   warn = arg[opt.index('-w')]
if '-n' in opt:
   netip = arg[opt.index('-n')]
else:
   err = 1
   msgerr.append('Network address is missing! The -n option is mandatory ;)')

if err == 1:
   for i in msgerr:
      print i
   sys.exit(3)

oid = ['1.3.6.1.4.1.311.1.3.2.1.1.3.'+netip]
client = role.manager((addr, port))

req = eval('v' + vers).GETREQUEST()
rsp = eval('v' + vers).GETRESPONSE()
(answer, src) = client.send_and_receive(req.encode(community=comm, encoded_oids=map(asn1.OBJECTID().encode, oid)))
rsp.decode(answer)

oids = map(lambda x: x[0], map(asn1.OBJECTID().decode, rsp['encoded_oids']))
vals = map(lambda x: x[0](), map(asn1.decode, rsp['encoded_vals']))

if vals[0] == '':
   print 'DHCP UNKNOWN'
   sys.exit(3)
elif vals[0] <= crit:
   print 'DHCP CRITICAL:',  str(vals[0])
   sys.exit(2)
elif vals[0] <= warn:
   print 'DHCP WARNING:',  str(vals[0])
   sys.exit(1)
else:
   print 'DHCP OK: ',  str(vals[0])
   sys.exit(0)
