#!/usr/local/bin/python2.7
#
# *** script for net_mgr batch jobs ***
# 
# last update:
# 5/1/2016 First version
# 5/2/2016 Add sysvar list
#          Add AppSysvar list
# 5/9/2016 Add Mac2IPv6
# 11/21/2016 Add dialog to ask which interface to use
# 5/31/2017 Add macID to sysvar.log
#           Add ASCII to some sysvars

import re
import subprocess
import os
import time
import logging

debug=0

class Test():
    def __init__(self, debug=1):        
        self.NETMGR = r"/home/ssnuser/work/net_mgr"
        self.fsu = self.NETMGR + ' -d'
        self.nic = self.NETMGR + ' -g -d'
        subprocess.call([self.NETMGR, "-V"])
        self.eth = self.GetEth()
        

    def GetEth(self):
        ifconfig_output = subprocess.check_output(['ifconfig'])
        if debug: print ifconfig_output
        eth_int = re.search('eth\d', ifconfig_output)
        if eth_int is not None:        
            return eth_int.group()
        else:
            return None
    
    def CallEth(self, ipv6, arg_list):
        args = [self.NETMGR, '-d', ipv6+'%'+self.eth] + arg_list
        try:        
            if self.eth is not None:
                output = subprocess.check_output(args)
            else:
                print 'Can not find eth interface'
        except subprocess.CalledProcessError, Argument:        
            print Argument
        else:    
            return output

    def CallFsu(self, ipv6, arg_list):
        args = [self.NETMGR, '-g', '-d', ipv6] + arg_list
        try:
            output = subprocess.check_output(args)        
        except subprocess.CalledProcessError, Argument:               
            print Argument
        else:
            return output
    
    #cm is call method, CallEth or CallNic
    def GetImageList(self, cm, ipv6):
        arg_list = ['image', 'list']       
        return cm(ipv6, arg_list)

    def GetSysvarList(self, cm, ipv6): 
        arg_list = ['sysvar', 'list']       
        return cm(ipv6, arg_list)
    
    def GetSingleSysvarValue(self, cm, ipv6, sysID):
        arg_list = ['sysvar', sysID]
        return cm(ipv6, arg_list)

    def GetSingleSysvarAsciiValue(self, cm, ipv6, sysID):
        arg_list = ['sysvar', 'ascii:%s' % sysID]
        return cm(ipv6, arg_list)
   
    def GetAppSysvarList(self, cm, ipv6): 
        arg_list = ['app_sysvar', 'list']       
        return cm(ipv6, arg_list)
    
    def GetSingleAppSysvarValue(self, cm, ipv6, sysID):
        arg_list = ['app_sysvar', sysID]
        return cm(ipv6, arg_list)

   
    def GetSysvarListValues(self, cm, ipv6):
        sysvarlist = self.GetSysvarList(cm, ipv6)
        ids = re.findall('\d{1,}(?=:)', sysvarlist)
        names = re.findall(r'(?<=\d:).*', sysvarlist)
        of =  ''.join(['='*20, 'SYSVAR %s' % ipv6, '='*20])
        print of
        output_str = []
        output_str.append(of)
        for i in range(len(ids)):
            sysvar_content = self.GetSingleSysvarValue(cm, ipv6, ids[i])            
            sysvar_value = re.search(r'(0x[0-9a-f]{2}:?){1,}',sysvar_content)
            sysvar_value_ascii = None     
            if ids[i] in ['117','131','132','147', '51', '50','49']:
                sysvar_content_ascii = self.GetSingleSysvarAsciiValue(cm, ipv6, ids[i])
                sysvar_value_ascii = re.search(r'(?<=: ).*',sysvar_content_ascii)
            #print sysvar_content, '....'
            try:         
                content = sysvar_value.group()
                content_ascii = sysvar_value_ascii.group()
            except AttributeError:
                content = sysvar_content
            of = '{0:4} - {1:30} - {2}'.format(ids[i], names[i], content)
            if sysvar_value_ascii is not None:
                of = of + '\n{0:37} - {1}'.format('', content_ascii)
            print of
            output_str.append(of)
        return '\n'.join(output_str)

    def GetAppSysvarListValues(self, cm, ipv6):
        sysvarlist = self.GetAppSysvarList(cm, ipv6)
        ids = re.findall('\d{1,}(?=:)', sysvarlist)
        names = re.findall(r'(?<=\d:).*', sysvarlist)
        of =  ''.join(['='*20, 'APP_SYSVAR %s' % ipv6, '='*20])
        print of
        output_str = []
        output_str.append(of)
        for i in range(len(ids)):
            sysvar_content = self.GetSingleAppSysvarValue(cm, ipv6, ids[i])
            sysvar_value = re.search(r'(0x[0-9a-f]{2}:?){1,}',sysvar_content) 
            #print sysvar_content, '....'
            try:         
                content = sysvar_value.group()
            except AttributeError:
                content = sysvar_content
            of = '{0:4} - {1:30} - {2}'.format(ids[i], names[i], content)
            print of
            output_str.append(of)
        return '\n'.join(output_str)

    def GetNetID(self, cm, ipv6):
        arg_list = ['conf', 'mlme', 'mlme_mac_net_id']
        return cm(ipv6, arg_list)

    def GetStartWord(self, cm, ipv6):
        arg_list = ['conf', 'phy', 'phy_start_word']
        return cm(ipv6, arg_list)

    def GetHWinfo(self, cm, ipv6):
        arg_list = ['hw_info', 'show']
        return cm(ipv6, arg_list)
 
    def Mac2IPv6(self, mac):
        '''
            Convert mac to ipv6
            from 
                00:13:50:ff:fe:40:00:e2 or
                001350fFFe4000E2      
            
            to fe80::213:50ff:fe40:e2
        '''
        mac = mac.replace(":", "")
        mac = mac.lower()
        ipv6 = 'fe80::'
        if len(mac) == 16:
            first_octet = mac[0:2]
            # invert 2nd bit of first_octet
            if int(first_octet) & 2 == 0:
                first_octet = int(first_octet) + 2
            else:
                first_octet = int(first_octet) - 2     
    
            # convert 2 to '02'
            first_octet = str(first_octet).zfill(2) 
            
            # convert 001350fffe4000e2 to 021350fffe4000e2
            mac = first_octet + mac[2:]
            
            # convert 021350fffe4000e2 to 0213:50ff:fe40:00e2
            mac = mac[:4] + ':' + mac[4:8] + ':' + mac[8:12] + ':' + mac[12:16]

            #
            ipv6 = ipv6 + mac
            return ipv6
            
        else:
            print 'missing %d number(s) in your mac ID' % (16 - len(mac))
            return 0
        
        


if __name__ == "__main__":
    quick_test = Test(debug)
    print 'Ethernet interface: ', quick_test.GetEth()  
    mac = raw_input('Enter MAC ID i.e. 001350fffe601234: ')
    mac = mac.replace(':','').upper()
    ipv6 = quick_test.Mac2IPv6(mac)

    logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d-%y %H:%M',
                    filename='sysvars_%s.log' % mac,
                    filemode='a')

    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

    logger = logging.getLogger('%s' % mac)

    while 1:
        interface = raw_input('Do you want to use FSU(1) or ETH(2): ')
        if interface == '1':
            intf = quick_test.CallFsu
            break
        elif interface == '2':
            intf = quick_test.CallEth            
            break
        else:
            print "Enter \'1\' to use FSU, or \'2\' to use Ethernet"            
            continue

    logger.info('test')
    logger.info(quick_test.GetImageList(intf, ipv6))
    #print quick_test.GetSysvarList(quick_test.CallEth, 'fe80::213:50ff:fe12:35f0')
    #print quick_test.GetImageList(quick_test.CallFsu, 'fe80::213:50ff:fe12:35f0')
    logger.info(quick_test.GetSysvarListValues(intf, ipv6))
    logger.info(quick_test.GetAppSysvarListValues(intf, ipv6))
    logger.info(quick_test.GetNetID(intf, ipv6))
    logger.info(quick_test.GetStartWord(intf, ipv6))
    logger.info(quick_test.GetHWinfo(intf, ipv6))

