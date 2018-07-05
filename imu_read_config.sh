#!/bin/bash

imu=$1
#NETMGR=/home/ssnuser/work/net_mgr
nic='/home/ssnuser/work/net_mgr -g -d'

commands=(
'image list'
'time_zone read'
'conf mlme mlme_reboot_cntr'
'conf mlme mlme_mac_net_id'
'conf phy phy_start_word'
'meter_dl_cfg'
'meter_sr_cfg'
'conf imu data_tx_sched'
'conf imu imu_stat_report_period'
'conf imu imu_meter_cfg_report_period'
'conf imu imu_max_tx_tries'
'conf imu rotation_const'
'conf imu meter_const'
'conf imu meter_group_id'
'conf imu number_of_dials'
'conf imu alarm_wake_mask'
'conf imu alarm_async_tx_mask'
'conf imu gmi_el_err_mask'
'conf imu alarm_mask'
'conf imu meter_capacity'
'conf imu meter_run_away'
'conf imu meter_averaging'
'conf imu atmega_saved_state'
'conf imu service_pulse_count'
'conf imu imu_service_time'
'app_sysvar 197'
'app_sysvar 491'
'app_sysvar 492'
'app_sysvar 493'
'app_sysvar 66'
'app_sysvar 67'
)

for i in "${!commands[@]}"
do
    arg=${commands[$i]}
    printf '\n'
    echo $imu
    echo $arg
    $nic $imu $arg
done
