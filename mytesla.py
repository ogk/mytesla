#!/usr/bin/env python
# encoding: utf-8

""" Very basic beginner project to experiment with connecting top my Tesla
using  https://github.com/gglockner/teslajson

"""


import os
import teslajson
import datetime

def establish_connection(token=None):
    c = teslajson.Connection(email=TESLA_EMAIL, password=TESLA_PASSWORD, access_token=token)
    return c
    
def get_odometer(c, car):
    odometer = None
    for v in c.vehicles:
        if v["display_name"] == car:
            d = v.data_request("vehicle_state")
            odometer = int(d["odometer"])
    return odometer
    
def miles_to_km(miles=0):
    return int(miles * 1.609)

def exit_if_logininfo_not_set():
    print "One or both environment variables TESLA_EMAIL or  TESLA_PASSWORD are not set."
    print "The must be set in the shell you are running from, e.g."
    print "    export TESLA_EMAIL=myemail"
    print "    export TESLA_PASSWORD=secret"
    print "   ", os.path.basename(__file__)
    print "or:"
    print "    TESLA_EMAIL=myemail TESLA_PASSWORD=secret", os.path.basename(__file__)
    print
    quit()

# Must be exported enviromnent variables set before running script
try:
    TESLA_EMAIL = os.environ['TESLA_EMAIL']
    TESLA_PASSWORD = os.environ['TESLA_PASSWORD']
except:
    exit_if_logininfo_not_set()

MY_CAR="K-2SO"

c = establish_connection()
print "{0} {1} km".format(datetime.datetime.now().isoformat(), miles_to_km(get_odometer(c, MY_CAR)) )

