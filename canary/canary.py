#!/usr/local/bin/python2.7
#
# *** script to handle net_mgr io ***
# 
# last update:
# 7/28/2017 first entry

import re
import subprocess
import os
import time
import logging
import sys
sys.path.append('../')
import pynm

check_interval = 600 #in seconds, how often to check for sysvar 360
canary_macid = '001350FFFE125B53'
test_macid = '001350FFFE125B54'
warning_filepath = r'/media/sf_TEMP/canary_device/WARNING_rf_contamination.canary'
remote_logs = r'/media/sf_TEMP/canary_device/logs'


NETMGR = r"/home/ssnuser/work/net_mgr"
canary = pynm.Test(debug=0, timeout=3)
intf = canary.CallEth
ipv6 = canary.Mac2IPv6(canary_macid)
test_ipv6 = canary.Mac2IPv6(test_macid)

def writeWarningFile(warning_message, flag='w+'):
    with open(warning_filepath, flag) as of:
        of.write(warning_message + '\n')

def boot2image(fwimage='mutt'):
    '''
        boot2image(fwimage='mutt') or (fwimage='prod')
    '''    
    imagelist = canary.GetImageList(intf, ipv6)
    print '...booting to %s image...' % fwimage
    if fwimage == 'mutt' or fwimage == 'prod':
        image2boot = canary.getFW(imagelist, fwimage)
        if image2boot is not None:
            setbootflag = ''
            setreboot = ''
            checkboot = ''
            while 'Successfully' not in setbootflag:
                setbootflag = canary.SetBoot(intf, ipv6, image2boot, image2boot)
                print '...attempting to boot to %s mode' % image2boot
                time.sleep(2)
            while 'Ok' not in setreboot:
                setreboot = canary.SetRestart(intf, ipv6)
                time.sleep(2)
                print '...restarting'
            while 'Image List' not in checkboot:
                checkboot = canary.GetImageList(intf,ipv6)
                time.sleep(5)                
                print '...checking if uut booted properly:'
                print checkboot
            print '...resume RF contamination check...'
        else:
            print '...no image to boot %s' % imagelist
    else:
        print '...fwimage should be either \'mutt\' or \'prod\', not %s' % fwimage


def removeCerts():
    boot2image('mutt')
    checkRemoval = ' '
    while 'Ok' not in checkRemoval:    
        checkRemoval = canary.RemoveAppSysvar(intf, ipv6, 360)
        print '...removing appsysvar 360 ... %s' % checkRemoval
        time.sleep(1)
    boot2image('prod')
    
def main():
    while True:
        nodeq = cleanNodeq = canary.GetNodeq(intf, ipv6)
        
        if '360' not in canary.GetAppSysvarList(intf, ipv6):
            print '%s - No RF contamination detected, checking again in %s minutes' % (time.ctime(), int(check_interval / 60))
            cleanNodeq = nodeq
            time.sleep(check_interval)
        elif '360' in canary.GetAppSysvarList(intf, ipv6):           
            if not os.path.exists(warning_filepath):
                warning_msg = 'RF Contamination Detected at %s\n' % time.ctime()
                print warning_msg
                print 'Check log file: %s' % warning_filepath
                writeWarningFile(warning_msg)
                writeWarningFile(nodeq, 'a')
                writeWarningFile(canary.GetAppSysvarList(intf, ipv6), 'a')
                writeWarningFile(canary.GetCerts(intf, ipv6), 'a')
                writeWarningFile(canary.GetCertsOwn(intf, ipv6), 'a')
                writeWarningFile(canary.GetNetID(intf, ipv6), 'a')
                writeWarningFile('=========canary node q before contamination was detected=========', 'a')
                writeWarningFile(cleanNodeq, 'a')
                removeCerts()
            else:                
                print '%s - Found appsysvar 360 in canary device, previous alert has not been acknowledged.' % time.ctime()
                while os.path.exists(warning_filepath):
                    time.sleep(10)
        else:
            print 'unknown error, re-try in 1 minute'
            time.sleep(60)

            
             
    

if __name__ == '__main__':
    main()



