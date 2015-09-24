#!/usr/bin/env python

'''
    Author: Tomer Azran - tomerazran@gmail.com
    Description: This nagios plugin will check NetBotz200 temperature and humidity sensor,
        and return the results. In addition, it produces performance data.
        for usage information, type check_netbotz.py -h.
    
    The plugin was tested on Centos 6.3 with python 2.6.
    Needed python snmp binding (net-snmp-python). 
    
    Copyright (C) 2012 - Tomer Azran

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
'''

import sys
from optparse import OptionParser
import netsnmp

RET_CODES = {"OK":0,
             "WARNING":1,
             "CRITICAL":2,
             "UNKNOWN":3}

ON_ERROR_RET_CODE = RET_CODES["CRITICAL"]

INDEX_OID =  'PowerNet-MIB::emsProbeStatusProbeIndex'
STATUS_OID = 'PowerNet-MIB::emsProbeStatusProbeCommStatus'
NAME_OID =   'PowerNet-MIB::emsProbeStatusProbeName'

TEMP_OID = "PowerNet-MIB::emsProbeStatusProbeTemperature"
TEMP_HIGH_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeHighTempThresh"
TEMP_LOW_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeLowTempThresh"
TEMP_MAX_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeMaxTempThresh"
TEMP_MIN_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeMinTempThresh"

HUMIDITY_OID = "PowerNet-MIB::emsProbeStatusProbeHumidity"
HUMIDITY_HIGH_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeHighHumidityThresh"
HUMIDITY_LOW_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeLowHumidityThresh"
HUMIDITY_MAX_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeMaxHumidityThresh"
HUMIDITY_MIN_TRESH_OID = "PowerNet-MIB::emsProbeStatusProbeMinHumidityThresh"

OID_MAP = {"TEMP":[TEMP_OID,TEMP_HIGH_TRESH_OID,TEMP_LOW_TRESH_OID,TEMP_MAX_TRESH_OID,TEMP_MIN_TRESH_OID],
           "HUMIDITY":[HUMIDITY_OID,HUMIDITY_HIGH_TRESH_OID,HUMIDITY_LOW_TRESH_OID,HUMIDITY_MAX_TRESH_OID,HUMIDITY_MIN_TRESH_OID]}

def parse_options():
    parser = OptionParser()
    parser.add_option("-H", "--host", dest="hostname",type="string", help="NetBotz Host Name", metavar="HOST")
    parser.add_option("-c", "--community", dest="community", default="public", type="string", help="SNMP Community Name. [Default:public]")
    parser.add_option("-t", "--type", dest="type", default="temp", type="string", help="Test Type. Valid values are 'temp' for tempratue test, and 'humid' for humidity tests. [Default:temp]")
    parser.add_option("-e", "--onerror", dest="onerror", default=2, type="int", help="On error exit code. Valid values are 1 for warning, 2 for critical. [Default:2]")
    
    return parser.parse_args()

def validate_parameters(options, args):
    
    if options.hostname == None:
        print "Error: host name or ip must be supplied."
        sys.exit(RET_CODES["UNKNOWN"])
        
    if options.type != "temp" and options.type != "humid":
        print "Error: type option %s is not allowed " % (options.type)
        sys.exit(RET_CODES["UNKNOWN"])
    
    if options.onerror != 1 and options.onerror != 2:
        print "Error: onerror option %s is not allowed " % (options.onerror)
        sys.exit(RET_CODES["UNKNOWN"])
        
def get_on_error_ret_code(onerror):
    
    if onerror == 1:
        return RET_CODES["WARNING"]
    else:
        return RET_CODES["CRITICAL"]

def check_netbotz(options):
    
    oids = []
    test_name = ""
    test_units = ""
    test_units_for_perf_data = ""
    
    if options.type == "temp":
        oids = OID_MAP["TEMP"]
        test_name = "Tempratue"
        test_units = "C"        
    else:
        oids = OID_MAP["HUMIDITY"]
        test_name = "Humidity"
        test_units = '% RH'
        test_units_for_perf_data = '%'
    
    indexs = netsnmp.snmpwalk(netsnmp.Varbind(INDEX_OID),
                                   Version=1,
                                   DestHost=options.hostname,
                                   Community=options.community)
    
    if len(indexs) < 1:
        return RET_CODES["UNKNOWN"],"UNKNOWN: Cannot interact with NetBotz SNMP Agent"
    
    return_values = {}
    
    for i in indexs:       
        
        status = netsnmp.snmpget(netsnmp.Varbind(STATUS_OID+"."+i),
                               Version=1,
                               DestHost=options.hostname,
                               Community=options.community)
        if status[0] == "2":
            sensor_name = netsnmp.snmpget(netsnmp.Varbind(NAME_OID+"."+i),
                               Version=1,
                               DestHost=options.hostname,
                               Community=options.community)[0]
                               
            return_values[i] = {"name":sensor_name,"value":0,"max_value":0,"min_value":0}
             
            return_values[i]["value"] = netsnmp.snmpget(netsnmp.Varbind(oids[0]+"."+i),
                                                       Version=1,
                                                       DestHost=options.hostname,
                                                       Community=options.community)[0]
            return_values[i]["high_value"] = netsnmp.snmpget(netsnmp.Varbind(oids[1]+"."+i),
                                                       Version=1,
                                                       DestHost=options.hostname,
                                                       Community=options.community)[0]
            return_values[i]["low_value"] = netsnmp.snmpget(netsnmp.Varbind(oids[2]+"."+i),
                                                       Version=1,
                                                       DestHost=options.hostname,
                                                       Community=options.community)[0]
            return_values[i]["max_value"] = netsnmp.snmpget(netsnmp.Varbind(oids[3]+"."+i),
                                                       Version=1,
                                                       DestHost=options.hostname,
                                                       Community=options.community)[0]
            return_values[i]["min_value"] = netsnmp.snmpget(netsnmp.Varbind(oids[4]+"."+i),
                                                       Version=1,
                                                       DestHost=options.hostname,
                                                       Community=options.community)[0]
    
    ret_code = RET_CODES["OK"]
    on_error_retcode = get_on_error_ret_code(options.onerror)
    desc = ""
    
    for key in return_values.keys():
        desc += "%s %s test: %s%s " % (return_values[key]["name"],test_name,return_values[key]["value"],test_units)
        if return_values[key]["value"] < return_values[key]["low_value"]:
            ret_code = on_error_retcode
            desc += " - The %s value is LOWER than allowed treshold. " % test_name
        elif return_values[key]["value"] > return_values[key]["high_value"]:
            ret_code = on_error_retcode
            desc += " - The %s value is HIGHER than allowed treshold. " % test_name
        
        desc += " - The %s value is OK. " % test_name
    
    desc = desc.rstrip(" ").rstrip(",")
    
    if ret_code == RET_CODES["OK"]:
        desc = "OK: "+desc
    else:
        desc = "ERROR: "+desc
        
    desc += " | "
    for key in return_values.keys():
        desc += "'%s %s'=%s%s;;;%s;%s; " % (return_values[key]["name"],
                                              test_name,
                                              return_values[key]["value"],
                                              test_units_for_perf_data,
                                              return_values[key]["max_value"],
                                              return_values[key]["min_value"])
        
    return ret_code,desc.rstrip(" ").rstrip(",")
    
def main():
    
    try:
        (options, args) = parse_options()
        validate_parameters(options, args)
        retcode,desc = check_netbotz(options)
        print desc
        sys.exit(retcode)
    except Exception,e:
        return RET_CODES["UNKNOWN"],"UNKNOWN: Unexpected error\n"+str(e)

if __name__ == '__main__':
    main()
