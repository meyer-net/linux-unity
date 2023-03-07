#!/bin/sh
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://oshit.thiszw.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：绑定变量，借助函数 
#------------------------------------------------

# 覆写变量系统
#---------- ENV VARS ---------- {
#---------- ENV VARS ---------- }

# 定义安装语法
#---------- SCRIPTS SUGAR ---------- {
SYS_SETUP_COMMAND="yum"
#---------- SCRIPTS SUGAR ---------- }

# 本机IP
# NET_HOST=$(ping -c 1 -t 1 enginx.net | grep 'PING' | awk '{print $3}' | sed 's/[(,)]//g')

# NR==1 第一行
LOCAL_IPV4="0.0.0.0"
get_ipv4 "LOCAL_IPV4"

LOCAL_IPV6="0:0:0:0:0:0:0:0"
get_ipv6 "LOCAL_IPV6"

# ip addr | grep "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/[0-9]*.*brd" | awk '{print $2}' | awk -F'/' '{print $1}' | awk 'END {print}'
LOCAL_HOST="0.0.0.0"
get_iplocal "LOCAL_HOST"

LOCAL_ID=$(echo \${LOCAL_HOST##*.})

SYS_IP_CONNECT=$(echo ${LOCAL_HOST} | sed 's@\.@-@g' | xargs -I {} echo "{}")
SYS_NEW_NAME="ip-${SYS_IP_CONNECT}"

# 路径转化
convert_path "NVM_PATH"

# 城市代码
COUNTRY_CODE="CN"
get_country_code "COUNTRY_CODE"

SYS_IP_CONNECT=$(echo ${LOCAL_HOST} | sed 's@\.@-@g' | xargs -I {} echo "{}")
SYS_NEW_NAME="ip-${SYS_IP_CONNECT}"

RANDOM_STR=""
rand_str "RANDOM_STR" 8

SYS_DOMAIN=""
bind_sysdomain "SYS_DOMAIN"