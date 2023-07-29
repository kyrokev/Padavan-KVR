#!/bin/sh
frpc_enable=`nvram get frpc_enable`
frps_enable=`nvram get frps_enable`
http_username=`nvram get http_username`
frpc="/tmp/frp/frpc"
frps="/tmp/frp/frps"
[ -f /etc/storage/frpc ] && frpc="/etc/storage/frpc"
[ -f /etc/storage/frps ] && frpc="/etc/storage/frps"
[ ! -d /tmp/frp ] && mkdir -p /tmp/frp
check_frp () 
{
[ "$frpc_enable" != "1" ] && frp_close
[ "$frps_enable" != "1" ] && frp_close
        [ ! -d /tmp/frp ] && mkdir -p /tmp/frp
	check_net
	result_net=$?
	if [ "$result_net" = "1" ] ;then
		if [ -z "`pidof frpc`" ] && [ "$frpc_enable" = "1" ];then
  sed -i '/frpc/d' /etc/storage/cron/crontabs/$http_username
  frpcver="`$frpc --version`"
  frp_ver=$(cat /etc/storage/frp_script.sh | grep frp_version | awk -F '=' '{print $2}' | tr -d 'v' | tr -d ' ') && [ ! -z $frp_ver ] && frp_ver="0.51.2"
  if [ ! -f $frpc ] ;then
  curl -L -k -S -o "/tmp/var/frp_linux_mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/fatedier/frp/releases/download/v""$frp_ver""/frp_""$frp_ver""_linux_mipsle.tar.gz"
  tar -xz -C  /tmp -f  /tmp/var/frp_linux_mipsle.tar.gz
  mv -f "/tmp/frp_""$frp_ver""_linux_mipsle/frpc" "$frpc"
  rm -rf "/tmp/frp_""$frp_ver""_linux_mipsle"
  chmod 777 "$frpc"
  [ -z "$frpcver" ] && rm -rf $frpc
  fi
  if [ ! -f $frpc ] ;then
  curl -L -k -S -o "/tmp/var/frp_linux_mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/fatedier/frp@releases/download/v""$frp_ver""/frp_""$frp_ver""_linux_mipsle.tar.gz"
  tar -xz -C  /tmp -f  /tmp/var/frp_linux_mipsle.tar.gz
  mv -f "/tmp/frp_""$frp_ver""_linux_mipsle/frpc" "$frpc"
  rm -rf "/tmp/frp_""$frp_ver""_linux_mipsle"
  chmod 777 "$frpc"
  [ -z "$frpcver" ] && rm -rf $frpc
  fi
  [ ! -f $frpc ] && check_dl
			frp_start
		fi
		if [ -z "`pidof frps`" ] && [ "$frps_enable" = "1" ];then
  sed -i '/frps/d' /etc/storage/cron/crontabs/$http_username
  frpsver="`$frps --version`"
   frp_ver=$(cat /etc/storage/frp_script.sh | grep frp_version | awk -F '=' '{print $2}' | tr -d 'v' | tr -d ' ') && [ ! -z $frp_ver ] && frp_ver="0.51.2"
  if [ ! -f $frps ] ;then
  curl -L -k -S -o "/tmp/var/frp_linux_mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/fatedier/frp/releases/download/v""$frp_ver""/frp_""$frp_ver""_linux_mipsle.tar.gz"
  tar -xz -C  /tmp -f  /tmp/var/frp_linux_mipsle.tar.gz
  mv -f "/tmp/frp_""$frp_ver""_linux_mipsle/frps" "$frps"
  rm -rf "/tmp/frp_""$frp_ver""_linux_mipsle"
  chmod 777 "$frps"
   [ -z "$frpsver" ] && rm -rf $frps
  fi
  if [ ! -f $frps ] ;then
  curl -L -k -S -o "/tmp/var/frp_linux_mipsle.tar.gz" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/fatedier/frp@releases/download/v""$frp_ver""/frp_""$frp_ver""_linux_mipsle.tar.gz"
  tar -xz -C  /tmp -f  /tmp/var/frp_linux_mipsle.tar.gz
  mv -f "/tmp/frp_""$frp_ver""_linux_mipsle/frps" "$frps"
  rm -rf "/tmp/frp_""$frp_ver""_linux_mipsle"
  chmod 777 "$frps"
  [ -z "$frpsver" ] && rm -rf $frps
  fi
  [ ! -f $frps ] && check_dl
			frp_start
		fi
	fi
}
check_dl() 
{
check_frp
}
check_net() 
{
	/bin/ping -c 3 223.5.5.5 -w 5 >/dev/null 2>&1
	if [ "$?" == "0" ]; then
		return 1
	else
		return 2
		logger -t "frp" "检测到互联网未能成功访问,稍后再尝试启动frp"
	fi
}

frp_start () 
{
frpc_tag="`$frpc --version`"
frps_tag="`$frps --version`"
[ "$frpc_enable" = "1" ] && [ ! -z "$frpc_enable" ] && rm -rf $frpc && check_frp
[ "$frps_enable" = "1" ] && [ ! -z "$frps_enable" ] && rm -rf $frps && check_frp
	/etc/storage/frp_script.sh
 if [ "$frpc_enable" = "1" ];then
	sed -i '/frpc/d' /etc/storage/cron/crontabs/$http_username
	cat >> /etc/storage/cron/crontabs/$http_username << EOF
*/1 * * * * test -z "\`pidof frpc\`" && /usr/bin/frp.sh C >/dev/null 2>&1
EOF
fi
 if [ "$frps_enable" = "1" ];then
	sed -i '/frps/d' /etc/storage/cron/crontabs/$http_username
	cat >> /etc/storage/cron/crontabs/$http_username << EOF
*/1 * * * * test -z "\`pidof frps\`" && /usr/bin/frp.sh C >/dev/null 2>&1
EOF
fi
	[ ! -z "`pidof frpc`" ] && logger -t "frp" "frpc启动成功"
	[ ! -z "`pidof frps`" ] && logger -t "frp" "frps启动成功"
}

frp_close () 
{
	if [ "$frpc_enable" = "0" ]; then
 sed -i '/frpc/d' /etc/storage/cron/crontabs/$http_username
		if [ ! -z "`pidof frpc`" ]; then
		killall -9 frpc frp_script.sh
		[ -z "`pidof frpc`" ] && logger -t "frp" "已停止 frpc"
	    fi
	fi
	if [ "$frps_enable" = "0" ]; then
 sed -i '/frps/d' /etc/storage/cron/crontabs/$http_username
		if [ ! -z "`pidof frps`" ]; then
		killall -9 frps frp_script.sh
		[ -z "`pidof frps`" ] && logger -t "frp" "已停止 frps"
	    fi
	fi
}


case $1 in
start)
	frp_start &
	;;
stop)
	frp_close &
	;;
C)
	check_frp
	;;
esac
