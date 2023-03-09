#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      Copyright https://devops.oshit.com/
#      Author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装标题：$title_name
# 软件名称：$soft_name
# 软件端口：$soft_port
# 软件大写分组与简称：$soft_upper_short_name
# 软件安装名称：$setup_name
# 软件授权用户名称&组：conda/conda
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_$soft_upper_short_name_SETUP_PORT=1$soft_port

##########################################################################################################

# 1-配置环境
function set_env_$soft_name()
{
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_$soft_name()
{
    echo_style_wrap_text "Starting 'install', hold on please"

	# local TMP_$soft_upper_short_name_SETUP_SH_NEWER="v0.0.0"
	# local TMP_$soft_upper_short_name_SETUP_SH_FILE_NEWER="install_$soft_name.sh"
	# set_github_soft_releases_newer_version "TMP_$soft_upper_short_name_SETUP_SH_NEWER" "${git_repo}"
	# exec_text_printf "TMP_$soft_upper_short_name_SETUP_SH_NEWER" "https://raw.githubusercontent.com/${git_repo}/%s/install.sh"
    # while_curl "${TMP_$soft_upper_short_name_SETUP_SH_NEWER} -o ${TMP_$soft_upper_short_name_SETUP_SH_FILE_NEWER} | bash ${TMP_$soft_upper_short_name_SETUP_SH_FILE_NEWER}"

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_DIR}"
	
	# 开始安装
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

	# 开始标准化	    
    # # 预先初始化一次，启动后才有文件生成
    # systemctl start $soft_name.service
	
    # 还原 & 创建 & 迁移
	## 日志
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	## 数据
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	# soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "/var/lib/$soft_name"
	## ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" 
	# ## ETC - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    # soft_path_restore_confirm_action "/etc/$soft_name"
	# ## ETC - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}"

	# # 创建链接规则
	## 工作
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_WORK_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_WORK_DIR}"
	## 日志
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	## 数据
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	## ETC - ①-2Y
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" "" "/etc/$soft_name" 
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" "" "/etc/$soft_name"
	# path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" 
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
	
    echo_style_wrap_text "Starting 'configuration', hold on please"

	# 开始配置
	## 环境变量或软连接 /etc/profile写进函数
	echo_etc_profile "$soft_upper_name_HOME=${TMP_$soft_upper_short_name_SETUP_DIR}"
	echo_etc_profile 'PATH=$$soft_upper_name_HOME/bin:$PATH'
	echo_etc_profile 'export PATH $soft_upper_name_HOME'

    ## 重新加载profile文件
	source /etc/profile

    # ## 修改服务运行用户
    # change_service_user conda conda

	# ## 授权权限，否则无法写入
	## create_user_if_not_exists conda conda
	# chown -R conda:conda ${TMP_$soft_upper_short_name_SETUP_DIR}
	# chown -R conda:conda ${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}
	# chown -R conda:conda ${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}
	# chown -R conda:conda ${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}

    # # 中止进程
    # systemctl stop $soft_name.service
	
	return $?
}

##########################################################################################################

# 5-测试软件
function test_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'test', hold on please"

	# 实验部分

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
	# 验证安装/启动
    # 当前启动命令 && 等待启动
    echo_style_wrap_text "Starting 'boot check', hold on please"
	
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

    ## 设置系统管理，开机启动
    echo_style_text "View the 'systemctl info'↓:"
    chkconfig $setup_name on
	systemctl enable $setup_name.service
	systemctl list-unit-files | grep $setup_name
	
	# 启动及状态检测
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'service status'↓:"
    systemctl start $setup_name.service

	exec_sleep 3 "Initing <$setup_name>, hold on please"
	
    echo "[-]">> logs/boot.log
	nohup systemctl status $setup_name.service >> logs/boot.log 2>&1 &
    cat logs/boot.log

    # echo "${TMP_SPLITER3}"
    # cat /var/log/$setup_name/$setup_name.log
	# echo "${TMP_SPLITER3}"
	# journalctl -u $setup_name --no-pager | less
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'version'↓:"
    su_bash_env_conda_channel_exec "$setup_name -v"
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'info'↓:"
    su_bash_env_conda_channel_exec "$setup_name info"

	## 等待执行完毕 产生端口
    echo_style_text "View the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <$soft_name> to port '${TMP_$soft_upper_short_name_SETUP_PORT}', wait for a moment" "lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}" 180 3
	lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_style_text "Echo the 'port↓' to iptables:"
	echo_soft_port ${TMP_$soft_upper_short_name_SETUP_PORT}
    
    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_style_text "Echo the 'web service init script'↓:"
    #echo_web_service_init_scripts "$soft_name${LOCAL_ID}" "$soft_name${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_$soft_upper_short_name_SETUP_PORT} "${LOCAL_HOST}"

    # 结束
    exec_sleep 10 "Boot <$soft_name> over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_ext_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

	return $?
}

# 安装驱动/插件
function setup_ext_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf', hold on please"

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
    local TMP_$soft_upper_short_name_CURRENT_DIR=$(pwd)
	local TMP_$soft_upper_short_name_SETUP_DIR=${SETUP_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR=${ATT_DIR}/${TMP_$soft_upper_short_name_SETUP_MARK_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_$soft_upper_short_name_SETUP_BIN_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/bin
	local TMP_$soft_upper_short_name_SETUP_WORK_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/work
	local TMP_$soft_upper_short_name_SETUP_LOGS_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/logs
	local TMP_$soft_upper_short_name_SETUP_DATA_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/data
	local TMP_$soft_upper_short_name_SETUP_ETC_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/etc

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
	# local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/$setup_name
    # path_not_exists_action "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "exec_step_$soft_name" "$title_name was installed"

    # soft_cmd_check_upgrade_action "$setup_name" "exec_step_$soft_name" "rpm update $setup_name"
	soft_rpm_check_action "$setup_name" "exec_step_$soft_name" "$title_name was installed"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "$title_name" "check_setup_$soft_name"