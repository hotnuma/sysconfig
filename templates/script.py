#!/usr/bin/env python3

import os, sys, subprocess
appname = os.path.basename(__file__)

def error_exit(msg):
    if msg == "": msg = "an error occurred"
    print("*** %s\nabort..." % msg)
    exit(1)

def usage_exit():
    print("*** usage :")
    print("%s /path/to/file.txt" % appname)
    print("%s -opt val" % appname)
    print("abort...")
    exit(1)

def runcmd(cmd):
    ret = subprocess.run(cmd, shell=True, capture_output=True)
    result = ret.stdout.decode()
    return (result, ret.returncode)

args = sys.argv
size = len(args)
if size < 2: usage_exit()

opt_val = ""
i = 1
while i < size:
    if args[i] == "-opt":
        i += 1
        if i >= size: error_exit("missing param")
        opt_val = args[i]
    else:
        error_exit("invalid param")
    i += 1

print(opt_val)

