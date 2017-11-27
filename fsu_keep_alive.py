#!/usr/local/bin/python2.7
#
# *** check fsu nodeq, if 'cant connect' then reconnect ***
# 
# update:
# 10/8/2017 first commit
# 11/26/2017 working version

import pynm
import subprocess
from subprocess import PIPE, STDOUT
import time


fsu = pynm.Test(debug=1, timeout=10)

def ConnectFSU():
    fsuConnect = r"/home/ssnuser/work/launchgwnccd.sh"
    args = [fsuConnect]
    p = subprocess.Popen(args, shell=True)

def CheckFSUonline():
    fsu_msg = fsu.CheckFSU()
    if 'refused' in fsu_msg:
        return False
    else:
        print 'FSU online',
        return True

if __name__ == '__main__':
    while True:
        if CheckFSUonline():
            print '.',
        else:
            print '%s fsu offline, reconnecting..' % time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            ConnectFSU()
        time.sleep(60)


