#!/bin/bash
NETMGR=/home/ssnuser/work/net_mgr
listIPv6=()

#arg='iso_gpio show' 
#grep='Input state:'
#arg='nodeq 0'
#arg='image setboot 4.0.6001 4.0.6001'
#arg='image list'
#arg='image remove 84.0.6000'
#arg='image upload firmware'
#arg='get_version_str'
#arg='conf mlme mlme_mac_net_id' #netID
#arg='conf phy phy_start_word' #startword
#arg='sysvar 211' #meter NIC device type, not for ap relay
#arg='conf meter_dt type'
arg='conf mlme mlme_reboot_cntr'
#arg='restart now'
#arg='conf phy phy_tx_pwr'
#arg='conf phy phy_pwr_out_900'
#arg='conf phy phy_max_pwr_out_900' #conducted
#arg='country_code show'
#arg='pwrinfo 0'
#arg='sysstat'
#arg='trnet show log'
#arg='iso_gpio show'
#arg='sysvar 93'
####### AP related ########
#arg='sysif show eth0'
#arg='sysvar 199:0x01'
#arg='sysvar 200:0x05:0x00:0x00:0x00'
#arg='sysvar 201:0x1d:0x00:0x00:0x00'
#arg='sysvar 202:0x22:0x00:0x00:0x00'
#arg='sysvar ascii:51:16:8.8.8.8'
#arg='sysvar 200'
#arg='sysvar 201'
#arg='sysvar 202'
#arg='sysvar ascii:51'
#arg='sysvar delete:775'
#arg='trnet show log'
####### Bridge Serial Port Setup#######
#arg='uart_conf read'
#arg='uart_conf setmode parity:no ws:8 stopbits:1 uartnum:1'
#arg='uart_conf setdriver driver:rawu uartnum:0'
#arg='uart_conf setdriver driver:rawu uartnum:1'
#arg='uart_conf persist' # this command save uart configs
#arg='comm_server_conf read'
#arg='comm_server_conf uart:0 type:tcp listen_port:2001 peer_port:2001'
#arg='comm_server_conf uart:1 type:tcp listen_port:2002 peer_port:2002'
####### RSSI power varying ######
#-70 is enabled, change to -50 is disabled
#arg='conf mac mac_pv_rssi'
####### lua script #######
#arg='lua config list'
#arg='lua config upload_init vars_noCH.lua ~/work/project/AP-5.0-ALT/Lua/vars_noCH_from_MichaelLee.lua'
#arg='lua config upload_init vars_noCH.lua ./vars_noCH_from_MichaelLee.lua'
#arg='lua config verify vars_noCH.lua'
#arg='lua config setboot vars_noCH.lua ap_init.lua ap_config.lua'
#arg='lua config setboot'
#arg='lua config confirm' #before running this, run config list to make sure all is good
####### for troubleshooting #####
#arg='image corelist'
#arg='conf battery calib_low_volt'


grep='\s'

declare listIPv6

getCore () {

    local inputMac=$1
    local core='some core'
    core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    $NETMGR -g -d $inputMac image coreload $core
    #besure you have downloaded all core before removing it.
    #$NETMGR -g -d $inputMac image coreremove $core
}

removeCore () {

    local inputMac=$1
    local core='some core'
    core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    #$NETMGR -g -d $inputMac image coreload $core
    #besure you have downloaded all core before removing it.
    $NETMGR -g -d $inputMac image coreremove $core
}


#to find eth number, type ifconfig
# AP 5.0; commented out, don't touch this
: <<'END'
listIPv6=(
      "fe80::213:50ff:fe40:00f0%eth5" 
	  "fe80::213:50ff:fe40:00fd%eth5"
	  #"fe80::213:50ff:fe40:00f3%eth5"
	  #"fe80::213:50ff:fe40:00ee"
	  "fe80::213:50ff:fe40:00e2%eth5"
	  )
END
: <<'END'
listMac=(
      "fe80::213:50ff:fe40:00f0" 
	  "fe80::213:50ff:fe40:00fd"
	  "fe80::213:50ff:fe40:00f3"
	  "fe80::213:50ff:fe40:00ee"
	  "fe80::213:50ff:fe40:00e2"
	  )
END
# end of comment for AP 5.0


# AP 5.0 ALT
#: <<'END'
listMac=(
        "fe80::213:50ff:fe60:05c1" #uut1 #upgraded to 4.0.1
        #"fe80::213:50ff:fe60:05ab" #uut2 removed from chamber
        "fe80::213:50ff:fe60:0581" #uut3
        "fe80::213:50ff:fe60:05ca" #uut4 
        "fe80::213:50ff:fe60:0598" #uut5 #converted to ethernet AP
        "fe80::213:50ff:fe60:05d7" #uut6
        "fe80::213:50ff:fe60:0584" #uut7 
        "fe80::213:50ff:fe60:059b" #uut8 
#        "fe80::213:50ff:fe60:0593" #uut9 removed from chamber
        "fe80::213:50ff:fe60:0583" #uut10
        "fe80::213:50ff:fe60:0bc6" #uut11 #has 4.0.1
        "fe80::213:50ff:fe60:0d71" #uut12 #has 4.0.1
        "fe80::213:50ff:fe60:0bab" #uut13 #has 4.0.1
        "fe80::213:50ff:fe60:05d8" #uut14
        "fe80::213:50ff:fe60:05ba" #uut15
        "fe80::213:50ff:fe60:05b1" #uut16
        "fe80::213:50ff:fe60:05b6" #uut17
        "fe80::213:50ff:fe60:05d5" #uut18
        "fe80::213:50ff:fe60:0597" #uut19
        "fe80::213:50ff:fe60:05c5" #uut20
        "fe80::213:50ff:fe60:05dd" #uut21
        "fe80::213:50ff:fe60:0586" #uut22
        "fe80::213:50ff:fe60:05d6" #uut23
        "fe80::213:50ff:fe60:05ac" #uut24
	  )
#END


: <<'END'
for item in "${listIPv6[@]}"
do
	printf "%s\n" % $item
	$NETMGR -d $item -t 30 $arg | grep $grep
	printf "\n"
done
END
#: <<'END'
for item in "${listMac[@]}"
do
	printf "%s\n" % $item
	$NETMGR -g -d $item -t 60 $arg | grep $grep
    #getCore $item
    #removeCore $item
	printf "\n"
done
#END
