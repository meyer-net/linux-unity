#!/bin/bash
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：公有变量 
#------------------------------------------------

#---------- SYS ---------- {
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

GUM_PATH="/usr/bin/gum"
PUP_PATH="/usr/bin/pup"
export LC_CTYPE="en_US.UTF-8"
export GUM_INPUT_CURSOR_FOREGROUND="#F4AC45"
export GUM_INPUT_PROMPT_FOREGROUND="#04B575"
#---------- SYS ---------- }

#---------- HARDWARE ---------- { 
# 主机名称
SYS_NAME=`hostname`

# 系统产品名称
SYS_PRODUCT_NAME=`dmidecode -t system | grep "Product Name" | awk -F':' '{print $NF}' | awk '{sub("^ *","");sub(" *$","");print}'`

# 系统位数
CPU_ARCHITECTURE=`lscpu | awk NR==1 | awk -F' ' '{print $NF}'`

# 系统版本
MAJOR_OS=`cat /etc/redhat-release | awk -F' ' '{print $1}'`
MAJOR_OS_LOWER=`echo ${MAJOR_OS} | tr 'A-Z' 'a-z'`
MAJOR_VERS=`grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d "." -f1`

# 处理器核心数
PROCESSOR_COUNT=`cat /proc/cpuinfo | grep "processor"| wc -l`

# 空闲内存数
MEMORY_FREE=`awk '($1 == "MemFree:"){print $2/1048576}' /proc/meminfo`

# GB -> BYTES
MEMORY_GB_FREE=${MEMORY_FREE%.*}

# 机器环境信息
SYSTEMD_DETECT_VIRT=`systemd-detect-virt`
DMIDECODE_MANUFACTURER=`dmidecode -t system | grep "Manufacturer" | awk -F':' '{print \$NF}' | xargs echo`

#---------- HARDWARE ---------- }

#---------- SYSTEM ---------- {
LOCAL_TIME=`date +"%Y-%m-%d %H:%M:%S"`
LOCAL_TIMESTAMP=`date -d "${LOCAL_TIME}" +%s` 
#---------- SYSTEM ---------- }

#---------- DIR ---------- {    
SETUP_DIR=/opt
DOCKER_SETUP_DIR=${SETUP_DIR}/docker
DOCKER_APP_SETUP_DIR=${SETUP_DIR}/docker_apps
# NVM_PATH=~/.nvm/nvm.sh
NVM_PATH=${SETUP_DIR}/nvm/nvm.sh
CURRENT_USER=`whoami`

DOWN_DIR=/home/${CURRENT_USER}/downloads
RPMS_DIR=${DOWN_DIR}/rpms
SH_DIR=${DOWN_DIR}/sh
REPO_DIR=/etc/yum.repos.d
CURL_DIR=${DOWN_DIR}/curl

# 默认找最大的磁盘 
# MOUNT_ROOT=$(df -k | awk '{print $2}' | awk '{if (NR>2) {print}}' | awk 'BEGIN {max = 0} {if ($1+0 > max+0) {max=$1 ;content=$0} } END {print content}' | xargs -I {} sh -c 'df -k | grep "$1" | awk "{print \$NF}" | cut -c2' -- {})
# 默认认可第一个挂载的磁盘为数据盘
# 修复PVE挂载盘后规则不一样，出现默认sdb，新增sda的情况
FDISK_L_SYS_DEFAULT=`fdisk -l | grep '^/dev/' | awk -F' ' '{print \$1}' | awk 'NR==1' | tr -d '0-9'  | awk -F'/' '{print \$NF}'`
LSBLK_DISKS_STR=`lsblk | grep "0 disk" | grep -v "^${FDISK_L_SYS_DEFAULT}" | awk 'NR==1{print \$1}' | xargs -I {} echo '/dev/{}'`
LSBLK_MOUNT_ROOT=`df -h | grep ${LSBLK_DISKS_STR:-":"} | awk -F' ' '{print \$NF}'`
if [ "${LSBLK_MOUNT_ROOT}" == "/" ]; then
    LSBLK_MOUNT_ROOT=
fi

MOUNT_ROOT=${LSBLK_MOUNT_ROOT:-"/mountdisk"}
MOUNT_DIR=${MOUNT_ROOT}
DEFAULT_DIR=/home/${CURRENT_USER}/default
ATT_DIR=${MOUNT_DIR}/etc
DATA_DIR=${MOUNT_DIR}/data
LOGS_DIR=${MOUNT_DIR}/logs
DOCKER_ATT_DIR=${ATT_DIR}/docker
DOCKER_DATA_DIR=${DATA_DIR}/docker
DOCKER_LOGS_DIR=${LOGS_DIR}/docker
DOCKER_APP_ATT_DIR=${ATT_DIR}/docker_apps
DOCKER_APP_DATA_DIR=${DATA_DIR}/docker_apps
DOCKER_APP_LOGS_DIR=${LOGS_DIR}/docker_apps

BACKUP_DIR=${MOUNT_DIR}/repo/backup
COVER_DIR=${MOUNT_DIR}/repo/cover
FORCE_DIR=${MOUNT_DIR}/repo/force
MIGRATE_DIR=${MOUNT_DIR}/repo/migrate

CRTB_LOGS_DIR=${LOGS_DIR}/crontab
SYNC_DIR=${MOUNT_DIR}/svr_sync
WWW_DIR=${SYNC_DIR}/wwwroot
WWW_INIT_DIR=${WWW_DIR}/init
APP_DIR=${SYNC_DIR}/applications
PYA_DIR=${APP_DIR}/py
BOOT_DIR=${SYNC_DIR}/boots
PRJ_DIR=${WWW_DIR}/prj/www
OR_DIR=${PRJ_DIR}/or
PY_DIR=${PRJ_DIR}/py
JV_DIR=${PRJ_DIR}/java
HTML_DIR=${PRJ_DIR}/html
NGINX_DIR=${BOOT_DIR}/nginx
DOCKER_DIR=${DATA_DIR}/docker

JAVA_HOME=${SETUP_DIR}/java
MYCAT_DIR=${SETUP_DIR}/mycat
CONDA_HOME=${SETUP_DIR}/conda
CONDA_SCRIPTS_DIR=${CONDA_HOME}/scripts
CONDA_PW_SCRIPTS_DIR=${CONDA_SCRIPTS_DIR}/playwright/py
PY_ENV="pyenv37"
PY_PKGS_SETUP_DIR=${SETUP_DIR}/python_packages
PY3_PKGS_SETUP_DIR=${SETUP_DIR}/python3_packages
SUPERVISOR_ATT_DIR=${ATT_DIR}/supervisor
DOCKER_NETWORK="cuckoo-network"

#---------- DIR ---------- }

CHOICE_CTX="x"
TMP_SPLITER="------------------------------------------------------------------"
TMP_SPLITER2="---------------------------------"
TMP_SPLITER3="----------------------"