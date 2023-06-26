#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      Copyright https://devops.oshit.com/
#      Author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装时版本：4.2.5
#------------------------------------------------
# Debug：
#------------------------------------------------
# 安装标题：Supervisor
# 软件名称：supervisor
# 软件端口：$soft_port
# 软件大写分组与简称：SUP
# 软件安装名称：supervisor
#------------------------------------------------
local TMP_SUP_SETUP_HTTP_PORT=19001

##########################################################################################################

# 1-配置环境
function set_env_supervisor()
{
    echo_style_wrap_text "Starting 'configuare install envs' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_supervisor()
{
    echo_style_wrap_text "Starting 'install' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_SUP_SETUP_DIR}"
	
	# 开始安装
	cd ${TMP_SUP_SETUP_DIR}
	
    # 安装初始
	## 配置自定义执行脚本
	### 获取真实安装的路径
    cat >${TMP_SUP_SETUP_MCD_ENVS_DIR}/bin/supervisor<<EOF
#!/bin/bash
#
# supervisord   This scripts turns supervisord on
# chkconfig:    345 83 04
# description:  supervisor is a process control utility.  It has a web based
#              xmlrpc interface as well as a few other nifty features.
#
# examples: supervisorctl -c /etc/supervisor.conf start xxx

# source function library
. /etc/rc.d/init.d/functions

set -a

PREFIX=${TMP_SUP_SETUP_MCD_ENVS_DIR}

SUPERVISORD=\$PREFIX/bin/supervisord
SUPERVISORCTL=\$PREFIX/bin/supervisorctl

PIDFILE=/tmp/supervisord.pid
LOCKFILE=/tmp/supervisord.lock

OPTIONS="-c ${TMP_SUP_SETUP_LNK_CONF_DIR}/supervisor.conf"

# unset this variable if you don't care to wait for child processes to shutdown before removing the \$LOCKFILE-lock
WAIT_FOR_SUBPROCESSES=yes

# remove this if you manage number of open files in some other fashion
# ulimit -n 96000

RETVAL=0

# Fix exception Running
if [ -e \$PIDFILE ]; then 
    SUPERVISORD_RUNNING_DATA=\$(ps -fe | grep supervisord | grep -v grep)
    if [ -z "\$SUPERVISORD_RUNNING_DATA" ]; then
        echo "Clean pid & lock files"
        rm -rf /tmp/supervisor*
        rm -rf ${TMP_SUP_SETUP_LOGS_DIR}/*
    fi
fi

running_pid()
{
    # Check if a given process pid's cmdline matches a given name
    pid=\$1
    name=\$2
    [ -z "\$pid" ] && return 1
    [ ! -d /proc/\$pid ] && return 1
    (cat /proc/\$pid/cmdline | tr "\000" "\n"|grep -q \$name) || return 1
    return 0
}

running()
{
    # Check if the process is running looking at /proc
    # (works for all users)

    # No pidfile, probably no daemon present
    [ ! -f "\$PIDFILE" ] && return 1
    # Obtain the pid and check it against the binary name
    pid=\$(cat \$PIDFILE)
    running_pid \$pid \$SUPERVISORD || return 1
    return 0
}

start() 
{
    echo "Starting supervisord: "

    if [ -e \$PIDFILE ]; then 
        echo "ALREADY STARTED"
        return 1
    fi

    # start supervisord with options from sysconfig (stuff like -c)
    \$SUPERVISORD \$OPTIONS

    # show initial startup status
    \$SUPERVISORCTL \$OPTIONS status

    # only create the subsyslock if we created the PIDFILE
    [ -e \$PIDFILE ] && touch \$LOCKFILE
}

stop() 
{
    total_sleep=0
    echo -n "Stopping supervisord: "
    \$SUPERVISORCTL \$OPTIONS shutdown
    if [ -n "\$WAIT_FOR_SUBPROCESSES" ]; then 
        echo "Waiting roughly 60 seconds for \$PIDFILE to be removed after child processes exit"
        for sleep in 2 2 2 2 4 4 4 4 8 8 8 8 0; do
            if [[ ! -e \$PIDFILE ]] ; then
                echo "Supervisord exited as expected in under \$total_sleep seconds"
                break
            else
                if [ \$sleep -eq 0 ]; then
                    echo "Supervisord still working on shutting down. We've waited roughly 60 seconds, we'll let it do its thing from here"
                    return 1
                else
                    echo "taking for \$sleep seconds wait..."
                    sleep \$sleep
                    total_sleep+=\$sleep
                fi
            fi
        done
    fi

    # always remove the subsys. We might have waited a while, but just remove it at this point.
    rm -f \$LOCKFILE
    rm -f \$PIDFILE
}

restart() 
{
    stop
    start
}

case "\$1" in
start)
    start
    RETVAL=$?
    ;;
stop)
    stop
    RETVAL=$?
    ;;
restart|force-reload)
    restart
    RETVAL=$?
    ;;
reload)
    \$SUPERVISORCTL \$OPTIONS reload
    RETVAL=$?
    ;;
condrestart)
    [ -f \$LOCKFILE ] && restart
    RETVAL=$?
    ;;
status)
	[[ -a \$(cat ${TMP_SUP_SETUP_LNK_CONF_DIR}/supervisor.conf | grep -oP "(?<=^serverurl=unix://)[^;]+") ]] && \$SUPERVISORCTL \$OPTIONS status
	running
	RETVAL=$?
    ;;
*)
    echo $"Usage: \$0 {start|stop|status|restart|reload|force-reload|condrestart}"
    exit 1
esac

exit \$RETVAL
EOF

    chmod +x ${TMP_SUP_SETUP_MCD_ENVS_DIR}/bin/supervisor

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_supervisor()
{
	cd ${TMP_SUP_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	# 开始标准化（还原 & 创建 & 迁移）
	## 日志
	soft_path_restore_confirm_create "${TMP_SUP_SETUP_LNK_LOGS_DIR}"
	## 数据
	soft_path_restore_confirm_create "${TMP_SUP_SETUP_LNK_DATA_DIR}"
	## CONF - ②-N：不存在配置文件：
	soft_path_restore_confirm_create "${TMP_SUP_SETUP_LNK_CONF_DIR}"
    ## CONF - 手动生成文件
	path_not_exists_action "${TMP_SUP_SETUP_LNK_CONF_DIR}/supervisor.conf" "su_bash_env_conda_channel_exec 'cd && echo_supervisord_conf > ${TMP_SUP_SETUP_LNK_CONF_DIR}/supervisor.conf' '${TMP_SUP_SETUP_ENV}'"
	
	# 创建链接规则
	## 工作
	path_not_exists_link "${TMP_SUP_SETUP_WORK_DIR}" "" "${TMP_SUP_SETUP_LNK_WORK_DIR}"
	## 日志
	path_not_exists_link "${TMP_SUP_SETUP_LOGS_DIR}" "" "${TMP_SUP_SETUP_LNK_LOGS_DIR}"
	## 数据
	path_not_exists_link "${TMP_SUP_SETUP_DATA_DIR}" "" "${TMP_SUP_SETUP_LNK_DATA_DIR}"
	## CONF - ①-2Y
    path_not_exists_link "${TMP_SUP_SETUP_CONF_DIR}" "" "${TMP_SUP_SETUP_LNK_CONF_DIR}"
    # 安装不产生规格下的bin目录，所以手动还原创建
	path_not_exists_create "${TMP_SUP_SETUP_BIN_DIR}" "" "path_not_exists_link '${TMP_SUP_SETUP_BIN_DIR}/supervisor' '' '${TMP_SUP_SETUP_MCD_ENVS_DIR}/bin/supervisor'"
	path_not_exists_create "${TMP_SUP_SETUP_LNK_CONF_DIR}/boots"

	# 预实验部分

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_supervisor()
{
	cd ${TMP_SUP_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	# 开始配置
	## 环境变量或软连接 /etc/profile写进函数
	su_bash_conda_echo_profile "SUPERVISOR_HOME=${TMP_SUP_SETUP_DIR}" "" "${TMP_SUP_SETUP_ENV}"
	su_bash_conda_echo_profile 'PATH=$SUPERVISOR_HOME/bin:$PATH' "" "${TMP_SUP_SETUP_ENV}"
	su_bash_conda_echo_profile 'export PATH SUPERVISOR_HOME' "" "${TMP_SUP_SETUP_ENV}"
	
	## 修改配置文件
    sed -i "s@^[;]*\[inet_http_server\]@\[inet_http_server\]@g" ${DEPLOY_CONF_MARK}/supervisor.conf
    sed -i "s@^[;]*port=.*@port=${LOCAL_HOST}:${TMP_SUP_SETUP_HTTP_PORT}@g" ${DEPLOY_CONF_MARK}/supervisor.conf
    sed -i "s@^[;]*logfile=.*@logfile=${TMP_SUP_SETUP_LNK_LOGS_DIR}/supervisor.log@g" ${DEPLOY_CONF_MARK}/supervisor.conf
    sed -i "s@^[;]*\[include\]@\[include\]@g" ${DEPLOY_CONF_MARK}/supervisor.conf
    sed -i "s@^[;]*files = .*@files = ${TMP_SUP_SETUP_LNK_CONF_DIR}/boots/*.conf@g" ${DEPLOY_CONF_MARK}/supervisor.conf

	## 授权权限，否则无法写入 
	chown -R conda:root ${TMP_SUP_SETUP_DIR}
	chown -R conda:root ${TMP_SUP_SETUP_LNK_WORK_DIR}
	chown -R conda:root ${TMP_SUP_SETUP_LNK_LOGS_DIR}
	chown -R conda:root ${TMP_SUP_SETUP_LNK_DATA_DIR}
	chown -R conda:root ${TMP_SUP_SETUP_LNK_CONF_DIR}
	
    ## 目录调整完重启进程(目录调整是否有效的验证点)
    su_bash_env_conda_channel_exec "supervisor status" "${TMP_SUP_SETUP_ENV}"

	return $?
}

##########################################################################################################

# 5-测试软件
function test_supervisor()
{
	cd ${TMP_SUP_SETUP_DIR}

    echo_style_wrap_text "Starting 'test' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	# 实验部分

	return $?
}

##########################################################################################################
# 6-启动软件
function boot_supervisor()
{
	cd ${TMP_SUP_SETUP_DIR}
	
	# 验证安装/启动
    # 当前启动命令 && 等待启动
    echo_style_wrap_text "Starting 'boot check' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	# 配置服务
	## 启动配置加载
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'systemctl conf'↓:"
	local TMP_SUP_SETUP_MCD_ENV_HOME=$(su_bash_env_conda_channel_exec "cd;pwd" "${TMP_SUP_SETUP_ENV}")
	### 服务必须再docker.service启动之前运行
	tee /usr/lib/systemd/system/supervisor.service <<-EOF
# supervisord service for systemd (CentOS 7.0+)

[Unit]
Description=Supervisor daemon
After=rc-local.service network.target
Before=docker.service

[Service]
Type=forking
User=conda
Group=root
WorkingDirectory=${TMP_SUP_SETUP_MCD_ENV_HOME}
ExecStart=/bin/bash -c "source .bashrc && conda activate ${TMP_SUP_SETUP_ENV} && supervisor start"
ExecStop=/bin/bash -c "source .bashrc && conda activate ${TMP_SUP_SETUP_ENV} && supervisor stop"
ExecReload=/bin/bash -c "source .bashrc && conda activate ${TMP_SUP_SETUP_ENV} && supervisor reload"
KillMode=process
Restart=on-failure
RestartSec=42s
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload

    ## 设置系统管理，开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'systemctl info'↓:"
    chkconfig supervisor on
	systemctl enable supervisor.service
	systemctl list-unit-files | grep supervisor
	
	## 启动及状态检测
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'service status'↓:"
    systemctl start supervisor.service

    exec_sleep 3 "Initing <supervisor> in env(<${TMP_SUP_SETUP_ENV}>), hold on please"
	
    echo "[-]">> logs/boot.log
	systemctl status supervisor.service >> logs/boot.log
    cat logs/boot.log
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'version'↓:"
    su_bash_env_conda_channel_exec "supervisord -v" "${TMP_SUP_SETUP_ENV}"
	
	echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'help'↓:"
    su_bash_env_conda_channel_exec "supervisord -h" "${TMP_SUP_SETUP_ENV}"
	
	## 等待执行完毕 产生端口
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <supervisor> to port '${TMP_SUP_SETUP_HTTP_PORT}', wait for a moment" "lsof -i:${TMP_SUP_SETUP_HTTP_PORT}" 180 3
	lsof -i:${TMP_SUP_SETUP_HTTP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'port'(<${TMP_SUP_SETUP_HTTP_PORT}>) to iptables:↓"
	echo_soft_port ${TMP_SUP_SETUP_HTTP_PORT}
    
    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'web service init script'↓:"
    echo_web_service_init_scripts "supervisor${LOCAL_ID}" "supervisor${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_SUP_SETUP_HTTP_PORT} "${LOCAL_HOST}"
    
    # 结束
    exec_sleep 10 "Boot <supervisor> over, please checking the setup log, this will stay %s secs to exit"

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_ext_supervisor()
{
    cd ${TMP_SUP_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	return $?
}

# 安装驱动/插件
function setup_ext_supervisor()
{
    cd ${TMP_SUP_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_supervisor()
{
    cd ${TMP_SUP_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' in env(<${TMP_SUP_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_supervisor()
{
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_SUP_SETUP_NAME="${1}"
    local TMP_SUP_SETUP_MARK_NAME="${1/\//_}"
    local TMP_SUP_SETUP_VER="${2}"
    local TMP_SUP_SETUP_ENV="${3}"
    local TMP_SUP_SETUP_LNK_WORK_DIR="${4}"
	
	## 环境变量 
	local TMP_SUP_SETUP_MCD_SETUP_DIR=$(su_bash_env_conda_channel_exec "conda info --base" "${TMP_SUP_SETUP_ENV}")
	local TMP_SUP_SETUP_MCD_ENVS_DIR=${TMP_SUP_SETUP_MCD_SETUP_DIR}/envs/${TMP_SUP_SETUP_ENV}
	
	## 统一编排到的路径
    local TMP_SUP_CURRENT_DIR=$(pwd)
	local TMP_SUP_SETUP_DIR=${CONDA_APP_SETUP_DIR}/${TMP_SUP_SETUP_MARK_NAME}
	local TMP_SUP_SETUP_LNK_LOGS_DIR=${CONDA_APP_LOGS_DIR}/${TMP_SUP_SETUP_MARK_NAME}
	local TMP_SUP_SETUP_LNK_DATA_DIR=${CONDA_APP_DATA_DIR}/${TMP_SUP_SETUP_MARK_NAME}
	local TMP_SUP_SETUP_LNK_CONF_DIR=${CONDA_APP_CONF_DIR}/${TMP_SUP_SETUP_MARK_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_SUP_SETUP_BIN_DIR=${TMP_SUP_SETUP_DIR}/bin
	local TMP_SUP_SETUP_WORK_DIR=${TMP_SUP_SETUP_DIR}/${DEPLOY_WORK_MARK}
	local TMP_SUP_SETUP_LOGS_DIR=${TMP_SUP_SETUP_DIR}/${DEPLOY_LOGS_MARK}
	local TMP_SUP_SETUP_DATA_DIR=${TMP_SUP_SETUP_DIR}/scripts
	local TMP_SUP_SETUP_CONF_DIR=${TMP_SUP_SETUP_DIR}/${DEPLOY_CONF_MARK}

	set_env_supervisor 

	setup_supervisor 
	
	formal_supervisor 

	conf_supervisor 
	
	test_supervisor 

    down_ext_supervisor 
    setup_ext_supervisor 

	boot_supervisor 

	# reconf_supervisor 

    # 结束
    exec_sleep 30 "Install <supervisor> over, please checking the setup log, this will stay %s secs to exit"

	return $?
}

##########################################################################################################

# x1-检测软件安装
function check_setup_supervisor()
{
	soft_setup_conda_pip "supervisor" "exec_step_supervisor"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "Supervisor" "check_setup_supervisor"