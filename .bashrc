export HISTCONTROL=ignoredups:erasedups
#export PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"
alias ls="ls -lrt --color"
PS1='${PWD#"${PWD%/*/*}/"} \$ '
cd ~/work
alias nm=~/work/net_mgr
alias mac2ip=~/work/mac2ip
alias macDisc=~/work/macDisc
alias eldata=~/work/eldata_get
alias quick_test=~/work/quick_test.sh
alias fsu="~/work/net_mgr -i"
alias fsu_netid="~/work/net_mgr -i conf mlme mlme_mac_net_id"
alias fsu_startword="~/work/net_mgr -i conf phy phy_start_word"
alias nic="~/work/net_mgr -g -d"
alias eth="~/work/net_mgr -d"
alias test=~/work/test.py

# read meter event log
meterELstate() {
    ipv6=$1
    logs=$2
    elstate=$(nic $ipv6 meter_el_state | sed 's/[^0-9]//g')
	elstate1=$(echo $elstate | awk {'printf $1'})
	elstate2=$(echo $elstate | awk {'printf $2'})

    let "a=elstate2-logs"

    nic $1 gmi nic_el_read "$a":"$elstate2"
    echo "Read last $logs sequences"
    echo "first EL sequence:" $elstate1
    echo "last EL sequence:" $elstate2

}

alias readel=meterELstate

neighdisc() {
  macid=$1
  fsu mlme_disc_mac $macid
  fsu nodeq 0 | grep ${macid: -2}
}

