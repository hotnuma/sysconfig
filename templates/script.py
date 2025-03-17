#!/usr/bin/env python3

import os, sys, subprocess

appname = os.path.basename(__file__)

def error_exit(msg):
    if msg == "": msg = "an error occurred"
    print("*** %s\nabort..." % msg)
    exit(1)

def usage_exit():
    print("*** usage :")
    print("%s -opt1" % appname)
    print("%s -opt2 bla" % appname)
    print("abort...")
    exit(1)

