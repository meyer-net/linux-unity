#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      Copyright https://devops.oshit.com/
#      Author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装版本：
#------------------------------------------------
# Debug：
#------------------------------------------------
# 安装标题：$title_name
# 软件名称：$soft_name
# 软件端口：$soft_port
# 软件大写名称：$soft_upper_name
# 软件大写分组与简称：$soft_upper_short_name
# 软件安装名称：$setup_name
#------------------------------------------------
local TMP_$soft_upper_short_name_SETUP_PORT=1$soft_port

##########################################################################################################

# 1-配置环境
function set_env_$soft_name()
{
    echo_style_wrap_text "Starting 'configuare install envs' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_$soft_name()
{
    echo_style_wrap_text "Starting 'install' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_DIR}"
	
	# 开始安装
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
    # # 执行环境内二次安装
    # su_bash_env_conda_channel_exec "export DISPLAY=:0 && $setup_name install" "${TMP_$soft_upper_short_name_SETUP_ENV}"

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	# 开始标准化	    
    # # 预先初始化一次，启动后才有文件生成
    # systemctl start $soft_name.service
	
    # 还原 & 创建 & 迁移
	## 日志
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"

	## 数据
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	
	# soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "/var/lib/$soft_name"
	## CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" 
	# ## CONF - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    # soft_path_restore_confirm_action "/etc/$soft_name"
	# ## CONF - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"

	# 创建链接规则（原始存在则使用）
	## 工作
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_WORK_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_WORK_DIR}"
	## 日志 - supervisor
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}/supervisor_${TMP_$soft_upper_short_name_SETUP_NAME}.log" "" "${SUPERVISOR_LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}.log"
	## 日志
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	## 数据
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	# ## CONF - ①-2Y
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" "" "/etc/$soft_name" 
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" "" "/etc/$soft_name"
	## CONF - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" 

    ## 安装不产生规格下的bin目录，所以手动还原创建
    # path_not_exists_create "${TMP_$soft_upper_short_name_SETUP_BIN_DIR}" "" "path_not_exists_link '${TMP_$soft_upper_short_name_SETUP_BIN_DIR}/$setup_name' '' '${TMP_$soft_upper_short_name_SETUP_MCD_ENVS_DIR}/bin/$setup_name'"
	
	# 预实验部分
    ## 目录调整完重启进程(目录调整是否有效的验证点)

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'configuration' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	# 开始配置
	## 环境变量或软连接 /etc/profile写进函数
	su_bash_conda_echo_profile "$soft_upper_name_HOME=${TMP_$soft_upper_short_name_SETUP_DIR}" "${TMP_$soft_upper_short_name_SETUP_ENV}"
	su_bash_conda_echo_profile 'PATH=$$soft_upper_name_HOME/bin:$PATH' "${TMP_$soft_upper_short_name_SETUP_ENV}"
	su_bash_conda_echo_profile 'export PATH $soft_upper_name_HOME' "${TMP_$soft_upper_short_name_SETUP_ENV}"

    # ## 修改服务运行用户
    # change_service_user conda conda

	## 授权权限，否则无法写入
	chown -R conda:root /etc/$setup_name.conf
	chown -R conda:root ${TMP_$soft_upper_short_name_SETUP_DIR}
	chown -R conda:root ${TMP_$soft_upper_short_name_SETUP_LNK_WORK_DIR}
	chown -R conda:root ${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}
	chown -R conda:root ${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}
	chown -R conda:root ${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}
	
	## 修改配置文件

    # # 调整进程
    # su_bash_env_conda_channel_exec "$soft_name status"
	
	return $?
}

##########################################################################################################

# 5-测试软件
function test_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'test' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	# 实验部分

	return $?
}

##########################################################################################################

# 6-启动及检测运行
function boot_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
	# 验证安装/启动
    # 当前启动命令 && 等待启动
    echo_style_wrap_text "Starting 'boot check' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"
	
	# 配置服务
	## 启动配置加载
# 	local TMP_$soft_upper_short_name_SETUP_MCD_ENV_HOME=$(su_bash_env_conda_channel_exec "cd;pwd" "${TMP_$soft_upper_short_name_SETUP_ENV}")
# 	tee /usr/lib/systemd/system/supervisor.service <<-EOF
# # supervisord service for systemd (CentOS 7.0+)

# [Unit]
# Description=Supervisor daemon
# After=rc-local.service docker.service

# [Service]
# Type=forking
# User=conda
# Group=conda
# WorkingDirectory=${TMP_$soft_upper_short_name_SETUP_MCD_ENV_HOME}
# ExecStart=/bin/bash -c "source .bashrc && conda activate ${TMP_$soft_upper_short_name_SETUP_ENV} && supervisor start"
# ExecStop=/bin/bash -c "source .bashrc && conda activate ${TMP_$soft_upper_short_name_SETUP_ENV} && supervisor stop"
# ExecReload=/bin/bash -c "source .bashrc && conda activate ${TMP_$soft_upper_short_name_SETUP_ENV} && supervisor reload"
# KillMode=process
# Restart=on-failure
# RestartSec=15s
# SysVStartPriority=99

# [Install]
# WantedBy=multi-user.target
# EOF

    # ## 设置系统管理，开机启动
    # echo_style_text "[View] the 'systemctl info'↓:"
    # chkconfig $setup_name on
	# systemctl enable $setup_name.service
	# systemctl list-unit-files | grep $setup_name
	
	# # 启动及状态检测
    # echo "${TMP_SPLITER2}"
    # echo_style_text "[View] the 'service status'↓:"
    # systemctl start $setup_name.service

    # # 等待启动
	# exec_sleep 3 "Initing <$setup_name> in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"
	
    # echo "[-]" >> logs/boot.log
	# systemctl status $setup_name.service >> logs/boot.log
	# echo "${TMP_SPLITER3}" >> logs/boot.log
	# journalctl -u $setup_name --no-pager >> logs/boot.log
    # cat logs/boot.log
	
    # 打印版本
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'version'↓:"
    su_bash_env_conda_channel_exec "$setup_name -v" "${TMP_$soft_upper_short_name_SETUP_ENV}"
    # su_bash_env_conda_channel_exec "$setup_name -V" "${TMP_$soft_upper_short_name_SETUP_ENV}"
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'help'↓:"
    su_bash_env_conda_channel_exec "$setup_name -h" "${TMP_$soft_upper_short_name_SETUP_ENV}"

	# 等待执行完毕 产生端口
    echo_style_text "[View] the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <$soft_name> to port '${TMP_$soft_upper_short_name_SETUP_PORT}', hold on please" "lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}" 180 3
	lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'port'(<${TMP_$soft_upper_short_name_SETUP_PORT}>) to iptables:↓"
	echo_soft_port ${TMP_$soft_upper_short_name_SETUP_PORT}

	# 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'supervisor startup conf'↓:"
	# echo_conda_startup_supervisor_config "${TMP_$soft_upper_short_name_SETUP_NAME}" "systemctl start ${TMP_$soft_upper_short_name_SETUP_NAME}.service" "999" "${TMP_$soft_upper_short_name_SETUP_ENV}" false 0
	echo_conda_startup_supervisor_config "${TMP_$soft_upper_short_name_SETUP_NAME}" "${TMP_$soft_upper_short_name_SETUP_NAME} start" "999" "${TMP_$soft_upper_short_name_SETUP_ENV}"
    
    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'web service init script'↓:"
    #echo_web_service_init_scripts "$soft_name${LOCAL_ID}" "$soft_name${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_$soft_upper_short_name_SETUP_PORT} "${LOCAL_HOST}"

    # 结束
    exec_sleep 10 "Boot <$soft_name> over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' in env(<${TMP_$soft_upper_short_name_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_$soft_name()
{
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_$soft_upper_short_name_SETUP_NAME="${1}"
    local TMP_$soft_upper_short_name_SETUP_MARK_NAME="${1/\//_}"
    local TMP_$soft_upper_short_name_SETUP_VER="${2}"
    local TMP_$soft_upper_short_name_SETUP_ENV="${3}"
    local TMP_$soft_upper_short_name_SETUP_LNK_WORK_DIR="${4}"
		
	## 环境变量 
	local TMP_$soft_upper_short_name_SETUP_MCD_SETUP_DIR=$(su_bash_env_conda_channel_exec "conda info --base" "${TMP_$soft_upper_short_name_SETUP_ENV}")
	local TMP_$soft_upper_short_name_SETUP_MCD_ENVS_DIR=${TMP_$soft_upper_short_name_SETUP_MCD_SETUP_DIR}/envs/${TMP_$soft_upper_short_name_SETUP_ENV}

	## 统一编排到的路径
	local TMP_$soft_upper_short_name_SETUP_DIR=${CONDA_APP_SETUP_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR=${CONDA_APP_LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${CONDA_APP_DATA_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR=${CONDA_APP_CONF_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_$soft_upper_short_name_SETUP_BIN_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/bin
	local TMP_$soft_upper_short_name_SETUP_WORK_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_WORK_MARK}
	local TMP_$soft_upper_short_name_SETUP_LOGS_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_LOGS_MARK}
	local TMP_$soft_upper_short_name_SETUP_DATA_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_DATA_MARK}
	local TMP_$soft_upper_short_name_SETUP_CONF_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/${DEPLOY_CONF_MARK}

	set_env_$soft_name 

	setup_$soft_name 
	
	formal_$soft_name 

	conf_$soft_name 
	
	test_$soft_name 

    # down_ext_$soft_name 
    # setup_ext_$soft_name 

	boot_$soft_name 

	# reconf_$soft_name 

	return $?
}

##########################################################################################################

# x1-检测软件安装
function check_setup_$soft_name()
{
	# 当前路径（仅记录）
	local TMP_$soft_upper_short_name_CURRENT_DIR=$(pwd)

    # 查找及确认版本
	# local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/$setup_name
    # path_not_exists_action "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "exec_step_$soft_name" "$title_name was installed"

    # soft_cmd_check_upgrade_action "$setup_name" "exec_step_$soft_name"
	soft_setup_conda_pip "$setup_name" "exec_step_$soft_name"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "$title_name" "check_setup_$soft_name"