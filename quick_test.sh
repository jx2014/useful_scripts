#!/bin/bash
NETMGR=/home/ssnuser/work/net_mgr
listIPv6=()

#arg='iso_gpio show' 
#grep='Input state:'
#arg='nodeq 0'
#arg='image setboot 4.2.6002, 4.2.6002'
arg='image list'
#arg='image remove 84.92.6009'
#arg='image remove 4.2.6002'
#arg='image upload fw'
#arg='get_version_str'
#arg='conf mlme mlme_mac_net_id' #netID
#arg='conf phy phy_start_word 0xfb17' #startword
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
#arg='trnet show device'
#arg='iso_gpio show'
#arg='sysvar 93'
#arg='conf srt on'
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
#arg='lua config confirm' #before running this, run config list to make sure all is good
#arg='lua config list'
#arg='lua config setboot alt-vars-vrz-LTE6.lua ap_init.lua mutt_config ap_config.lua'
#arg='lua config upload_init alt-vars-att-LTE4.lua'
#arg='lua config upload_init alt-vars-vrz-LTE6.lua'
#arg='lua config upload_init ap_init.lua'
#arg='lua config upload mutt_config'
#arg='lua config upload ap_config.lua'
#arg='lua config verify vars_noCH.lua'
#arg='lua config verify vars_file_vrz7.lua'
#arg='lua config setboot alt-vars-att-LTE4.lua ap_init.lua mutt_config ap_config.lua'
#arg='lua config list'
#arg='restart now'
####### for troubleshooting #####
#arg='conf wan_dialer stats_log_sensitivity 2' #default 2 for uAP
#arg='wan_itf list'
#arg='image corelist'
#arg='conf battery calib_low_volt'
#arg='trnet loglevel 5 0'
####### get ipv4 #######
#arg='trnet show log'
#arg='restart now'


grep='\s'

declare listIPv6

getCore () {

    local inputMac=$1
    local useEth=$2
    local core='some core'
    if (( $useEth > 0 )); then
        core=$($NETMGR -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
        if [ "$core" != "00.00.0000" ]; then $NETMGR -d $inputMac image coreload $core; fi
    else
        core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
        if [ "$core" != "00.00.0000" ]; then $NETMGR -g -d $inputMac image coreload $core; fi
    fi
    #besure you have downloaded all core before removing it.
    #$NETMGR -g -d $inputMac image coreremove $core
}

removeCore () {

    local inputMac=$1
    local useEth=$2
    local core='some core'
    if [[ $useEth > 0 ]]; then 
	core=$($NETMGR -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
        if [ "$core" != "00.00.0000" ]; then $NETMGR -d $inputMac image coreremove $core; fi
    else	
        core=$($NETMGR -g -d $inputMac image corelist | grep 'Image #0' | awk {'printf $3'})
        if [ "$core" != "00.00.0000" ]; then $NETMGR -g -d $inputMac image coreremove $core; fi
    fi
    #$NETMGR -g -d $inputMac image coreload $core
    #besure you have downloaded all core before removing it.
    
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
listMacs["UUT01"]="fe80::213:5008:0002:B0CC" 
listMacs["UUT02"]="fe80::213:5008:0002:B0ED" 
listMacs["UUT03"]="fe80::213:5008:0002:B0FA" 
listMacs["UUT04"]="fe80::213:5008:0002:B106" 
listMacs["UUT05"]="fe80::213:5008:0002:B0BE" 
listMacs["UUT06"]="fe80::213:5008:0002:B0FB" 
listMacs["UUT07"]="fe80::213:5008:0002:B0C5" 
listMacs["UUT08"]="fe80::213:5008:0002:B0F9" 
listMacs["UUT09"]="fe80::213:5008:0002:E0E5" 
listMacs["UUT10"]="fe80::213:5008:0002:E0CC"
listMacs["UUT11"]="fe80::213:5008:0002:E0CF"
listMacs["UUT12"]="fe80::213:5008:0002:E0F7"
listMacs["UUT13"]="fe80::213:5008:0002:E0E6"
listMacs["UUT14"]="fe80::213:5008:0002:E0D1"
listMacs["UUT15"]="fe80::213:5008:0002:E0DC"
listMacs["UUT16"]="fe80::213:5008:0002:7E45"
listMacs["UUT17"]="fe80::213:5008:0002:E0DD"
listMacs["UUT18"]="fe80::213:5008:0002:E0C9"
listMacs["UUT19"]="fe80::213:5008:0002:E0D3"
listMacs["UUT20"]="fe80::213:5008:0002:E0F5"
listMacs["UUT21"]="fe80::213:5008:0002:B102"
listMacs["UUT22"]="fe80::213:5008:0002:B0F2"
listMacs["UUT23"]="fe80::213:5008:0002:B0C6"
listMacs["UUT24"]="fe80::213:5008:0002:B0C7"
#new units
listMacs["UUT31"]="fe80::213:5008:0004:7509"
listMacs["UUT32"]="fe80::213:5008:0004:743D"
listMacs["UUT33"]="fe80::213:5008:0004:743C"
listMacs["UUT34"]="fe80::213:5008:0004:7506"
listMacs["UUT35"]="fe80::213:5008:0004:7508"
listMacs["UUT36"]="fe80::213:5008:0004:7489"
listMacs["UUT37"]="fe80::213:5008:0004:7630"
listMacs["UUT38"]="fe80::213:5008:0004:7405"
listMacs["UUT39"]="fe80::213:5008:0004:7534"
listMacs["UUT40"]="fe80::213:5008:0004:7583"
listMacs["UUT41"]="fe80::213:5008:0004:7478"
listMacs["UUT42"]="fe80::213:5008:0004:7465"
listMacs["UUT43"]="fe80::213:5008:0004:77FA"
listMacs["UUT44"]="fe80::213:5008:0004:7A08"
listMacs["UUT45"]="fe80::213:5008:0004:7A0A"
listMacs["UUT46"]="fe80::213:5008:0004:7A2E"
listMacs["UUT47"]="fe80::213:5008:0004:77FB"
listMacs["UUT48"]="fe80::213:5008:0004:77F8"
listMacs["UUT49"]="fe80::213:5008:0004:775B"
listMacs["UUT50"]="fe80::213:5008:0004:7759"
listMacs["UUT51"]="fe80::213:5008:0004:77D0"
listMacs["UUT52"]="fe80::213:5008:0004:7A2F"
listMacs["UUT53"]="fe80::213:5008:0004:7A0B"
listMacs["UUT54"]="fe80::213:5008:0004:7760"
#END

#: <<'END'
declare -A listIpv4
listIpv4["UUT1"]="166.201.205.178"
listIpv4["UUT2"]="166.201.205.197" 
listIpv4["UUT3"]="166.201.205.172" 
listIpv4["UUT4"]="166.201.205.208" 
listIpv4["UUT5"]="166.201.205.192" 
listIpv4["UUT6"]="166.201.205.243" 
listIpv4["UUT7"]="166.201.205.195"
listIpv4["UUT8"]="166.201.205.153"
listIpv4["UUT9"]="166.253.44.166" #verizon
listIpv4["UUT10"]="166.253.44.120" #verizon
listIpv4["UUT11"]="166.253.44.115" #verizon
listIpv4["UUT12"]="166.253.44.6" #verizon
listIpv4["UUT13"]="166.253.44.117" #verizon
listIpv4["UUT14"]="166.253.44.4"  #verizon
listIpv4["UUT15"]="166.253.44.118" #verizon 
listIpv4["UUT16"]="166.253.44.8" #verizon
listIpv4["UUT17"]="166.253.44.121" #verizon
listIpv4["UUT18"]="166.253.44.7" #verizon
listIpv4["UUT19"]="166.253.44.119" #verizon
listIpv4["UUT20"]="166.253.44.5" #verizon
listIpv4["UUT21"]="166.201.205.203"
listIpv4["UUT22"]="166.201.205.135"
listIpv4["UUT23"]="166.201.205.221"
listIpv4["UUT24"]="166.201.205.194"
#new units
listIpv4["UUT31"]="166.201.64.204"
listIpv4["UUT32"]="166.201.64.207"
listIpv4["UUT33"]="166.201.64.213"
listIpv4["UUT34"]="166.201.64.198"
listIpv4["UUT35"]="166.201.64.192"
listIpv4["UUT36"]="166.201.64.183"
listIpv4["UUT37"]="166.201.205.145"
listIpv4["UUT38"]="166.201.64.181"
listIpv4["UUT39"]="166.201.205.149"
listIpv4["UUT40"]="166.201.64.242"
listIpv4["UUT41"]="166.201.64.239"
listIpv4["UUT42"]="166.201.64.160"
listIpv4["UUT43"]="166.253.44.124" #verizon
listIpv4["UUT44"]="166.253.44.125" #verizon
listIpv4["UUT45"]="166.253.44.126" #verizon
listIpv4["UUT46"]="166.253.44.127" #verizon
listIpv4["UUT47"]="166.253.44.130" #verizon
listIpv4["UUT48"]="166.253.44.131" #verizon
listIpv4["UUT49"]="166.253.44.132" #verizon
listIpv4["UUT50"]="166.253.44.133" #verizon
listIpv4["UUT51"]="166.253.44.134" #verizon
listIpv4["UUT52"]="166.253.44.135" #verizon
listIpv4["UUT53"]="166.253.44.136" #verizon
listIpv4["UUT54"]="166.253.44.137" #verizon
#END


declare -a orders
#orders+=("UUT1") 
#orders+=("UUT2") 
#orders+=("UUT3") 
#orders+=("UUT4") 
#orders+=("UUT5") 
#orders+=("UUT6") 
#orders+=("UUT7") 
#orders+=("UUT8") 
#orders+=("UUT9")  #verizon
#orders+=("UUT10") #verizon 
#orders+=("UUT11") #verizon 
#orders+=("UUT12") #verizon 
#orders+=("UUT13") #verizon 
#orders+=("UUT14") #verizon 
#orders+=("UUT15") #verizon 
#orders+=("UUT16") #verizon 
#orders+=("UUT17") #verizon 
#orders+=("UUT18") #verizon 
#orders+=("UUT19") #verizon 
#orders+=("UUT20") #verizon
#orders+=("UUT21") 
#orders+=("UUT22") 
#orders+=("UUT23") 
#orders+=("UUT24")
#new units
#orders+=("UUT31") 
#orders+=("UUT32")
#orders+=("UUT33")
#orders+=("UUT34")
#orders+=("UUT35")
#orders+=("UUT36")
#orders+=("UUT37") 
#orders+=("UUT38")
#orders+=("UUT39")
#orders+=("UUT40")
#orders+=("UUT41")
#orders+=("UUT42")
orders+=("UUT43") #verizon
orders+=("UUT44") #verizon
orders+=("UUT45") #verizon
orders+=("UUT46") #verizon
orders+=("UUT47") #verizon
orders+=("UUT48") #verizon
orders+=("UUT49") #verizon
orders+=("UUT50") #verizon
orders+=("UUT51") #verizon
orders+=("UUT52") #verizon
orders+=("UUT53") #verizon
orders+=("UUT54") #verizon


: <<'END'
for item in "${listIPv6[@]}"
do
	printf "%s\n" % $item
	$NETMGR -d $item -t 30 $arg | grep $grep
	printf "\n"
done
END



#: <<'END'
timeout=60
useEth=0
loadCore=0
removeCore=0
for i in "${!orders[@]}"
do
    uut=${orders[$i]}
    if [[ $useEth > 0 ]]; then #use ethernet
        printf "$uut - ${listIpv4["$uut"]} - ${listMacs["$uut"]}\n"
        $NETMGR -d ${listIpv4["$uut"]} -t $timeout $arg | grep $grep
        if [[ $loadCore > 0 ]]; then
            getCore ${listIpv4["$uut"]} $useEth
        fi
        if [[ $removeCore > 0 ]]; then
            removeCore ${listIpv4["$uut"]} $useEth
        fi
        printf "\n"
    else
        printf "$uut - ${listMacs["$uut"]} - ${listIpv4["$uut"]}\n"
        $NETMGR -g -d ${listMacs["$uut"]} -t $timeout $arg | grep $grep        
        if [[ $loadCore > 0 ]]; then        
            getCore ${listMacs["$uut"]}
        fi
        if [[ $removeCore > 0 ]]; then        
            removeCore ${listMacs["$uut"]}
        fi
        printf "\n"
    fi
done
#END
