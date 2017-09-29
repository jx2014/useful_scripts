#!/bin/bash
NETMGR=/home/ssnuser/work/net_mgr
listIPv6=()

#arg='iso_gpio show' 
#grep='Input state:'
#arg='nodeq 0'
#arg='image setboot 4.92.6002 4.92.6002 force'
#arg='image list'
#arg='image remove 84.2.6000'
#arg='image remove 4.2.6001'
#arg='image upload firmware'
#arg='get_version_str'
#arg='conf mlme mlme_mac_net_id' #netID
#arg='conf phy phy_start_word' #startword
#arg='sysvar 211' #meter NIC device type, not for ap relay
#arg='conf meter_dt type'
#arg='conf mlme mlme_reboot_cntr'
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
#arg='sysvar 200:0x00:0x00:0x00:0x00'
#arg='sysvar 201:0x1d:0x00:0x00:0x00'
#arg='sysvar 202:0x22:0x00:0x00:0x00'
#arg='sysvar ascii:51:16:8.8.8.8'
#arg='sysvar 200'
#arg='sysvar 201'
#arg='sysvar 202'
#arg='sysvar 437'
#arg='sysvar ascii:51'
#arg='sysvar delete:775'
#arg='trnet show log'
#arg='trnet loglevel'
#arg='trnet loglevel 3'
#arg='trnet loglevel 5 0'
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
#arg='lua config upload_init vars_file_vrz7.lua /home/ssnuser/work/project/ALT-uAP-Gen5/lua/verizon/vars_file_vrz7.lua'
#arg='lua config upload_init vars_noCH.lua ./vars_noCH_from_MichaelLee.lua'
#arg='lua config verify vars_noCH.lua'
#arg='lua config verify vars_file_vrz7.lua'
#arg='lua config setboot vars_file_vrz7.lua ap_init.lua ap_config.lua'
#arg='lua config setboot'
#arg='lua config confirm' #before running this, run config list to make sure all is good
####### for troubleshooting #####
#arg='conf wan_dialer stats_log_sensitivity 0' #default 2 for uAP
#arg='wan_itf list'
arg='image corelist'
#arg='conf battery calib_low_volt'


grep='\s'

declare listIPv6

getCore () {

    local inputMac=$1
    local useEth=$2
    local core='some core'
    if (( $useEth > 0 )); then
        core=$($NETMGR -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    else
        core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    fi
    $NETMGR -g -d $inputMac image coreload $core
    #besure you have downloaded all core before removing it.
    #$NETMGR -g -d $inputMac image coreremove $core
}

removeCore () {

    local inputMac=$1
    local useEth=$2
    local core='some core'
    if (( $useEth > 0 )); then 
	core=$($NETMGR -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    else	
	core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
    fi
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


#: <<'END'
declare -A listMacs
listMacs["UUT1"]="fe80::213:5008:0002:7E1E" 
listMacs["UUT2"]="fe80::213:5008:0002:7E23" 
listMacs["UUT3"]="fe80::213:5008:0002:7E2A" 
listMacs["UUT4"]="fe80::213:5008:0002:7E30" 
listMacs["UUT5"]="fe80::213:5008:0002:7E2F" 
listMacs["UUT6"]="fe80::213:5008:0002:7E22" 
listMacs["UUT7"]="fe80::213:5008:0002:7E28" 
listMacs["UUT8"]="fe80::213:5008:0002:7E1F" 
listMacs["UUT9"]="fe80::213:5008:0002:7E2E" 
listMacs["UUT10"]="fe80::213:5008:0002:7E2D"
listMacs["UUT11"]="fe80::213:5008:0002:7E25"
listMacs["UUT12"]="fe80::213:5008:0002:7E1C"
listMacs["UUT13"]="fe80::213:5008:0002:7E48"
listMacs["UUT14"]="fe80::213:5008:0002:7E3B"
listMacs["UUT15"]="fe80::213:5008:0002:7E35"
listMacs["UUT16"]="fe80::213:5008:0002:7E42"
listMacs["UUT17"]="fe80::213:5008:0002:7E49"
listMacs["UUT18"]="fe80::213:5008:0002:7E3F"
listMacs["UUT19"]="fe80::213:5008:0002:7E45"
listMacs["UUT20"]="fe80::213:5008:0002:7E41"
listMacs["UUT21"]="fe80::213:5008:0002:7E46"
listMacs["UUT22"]="fe80::213:5008:0002:7E3A"
listMacs["UUT23"]="fe80::213:5008:0002:7E3D"
listMacs["UUT24"]="fe80::213:5008:0002:7E40"
#END

#: <<'END'
declare -A listIpv4
listIpv4["UUT1"]="166.201.205.247"
listIpv4["UUT2"]="166.201.205.251" 
listIpv4["UUT3"]="166.201.205.223" 
listIpv4["UUT4"]="166.201.205.225" 
listIpv4["UUT5"]="166.201.205.226" 
listIpv4["UUT6"]="166.201.205.191" 
listIpv4["UUT7"]="166.201.205.143" 
listIpv4["UUT8"]="166.201.205.142" 
listIpv4["UUT9"]="166.201.205.184" 
listIpv4["UUT10"]="166.201.205.202"
listIpv4["UUT11"]="166.201.64.176" 
listIpv4["UUT12"]="166.201.205.244"
listIpv4["UUT13"]="166.248.206.20" 
listIpv4["UUT14"]="166.248.206.21" 
listIpv4["UUT15"]="166.248.206.22" 
listIpv4["UUT16"]="166.248.206.23" 
listIpv4["UUT17"]="166.248.206.24" 
listIpv4["UUT18"]="166.253.23.246" 
listIpv4["UUT19"]="166.253.23.247" 
listIpv4["UUT20"]="166.253.23.248" 
listIpv4["UUT21"]="166.253.23.249" 
listIpv4["UUT22"]="166.253.44.1"   
listIpv4["UUT23"]="166.253.44.2"   
listIpv4["UUT24"]="166.253.44.3"
#END


declare -a orders
orders+=("UUT1") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT2") #has 4.92.6002 #changed to use serial instead of usb 
#orders+=("UUT3") #jx swap spansion
#orders+=("UUT4") #modem tp
orders+=("UUT5") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT6") #js debug and swap spansion
#orders+=("UUT7") #x-section
#orders+=("UUT8") #has 4.92.6002 #changed to use serial instead of usb 
#orders+=("UUT9") #has 4.92.6002 #changed to use serial instead of usb 
orders+=("UUT10") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT11") #x-section
#orders+=("UUT12") #modem TP probing at ssn
#orders+=("UUT13") #modem TP probing at ssn
orders+=("UUT14") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT15") #has 4.92.6002 remove from chamber/KimS
orders+=("UUT16") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT17") #has 4.92.6002 remove from chamber/KimS
orders+=("UUT18") #has 4.92.6002 # change to use serial instead of usb
#orders+=("UUT19") #modem TP probing at ssn
#orders+=("UUT20") #x-section
#orders+=("UUT21") #jx swap spansion
#orders+=("UUT22") #js debug
#orders+=("UUT23") #has 4.92.6002 #changed to use serial instead of usb 
orders+=("UUT24") #has 4.92.6002# change to use serial instead of usb


: <<'END'
for item in "${listIPv6[@]}"
do
	printf "%s\n" % $item
	$NETMGR -d $item -t 30 $arg | grep $grep
	printf "\n"
done
END



#: <<'END'
timeout=10
useEth=1
loadCore=0
removeCore=0
for i in "${!orders[@]}"
do
    uut=${orders[$i]}
    if [[ $useEth > 0 ]]; then #use ethernet
        printf "$uut - ${listIpv4["$uut"]} - ${listMacs["$uut"]}\n"
        $NETMGR -d ${listIpv4["$uut"]} -t $timeout $arg | grep $grep
        #getCore ${listIpv4["$uut"]} $useEth
        removeCore ${listIpv4["$uut"]} $useEth
        printf "\n"
    else
        printf "$uut - ${listMacs["$uut"]} - ${listIpv4["$uut"]}\n"
        $NETMGR -g -d ${listMacs["$uut"]} -t $timeout $arg | grep $grep        
        #getCore ${listMacs["$uut"]} $useEth
        #removeCore ${listMacs["$uut"]}
        printf "\n"
    fi
done
#END
