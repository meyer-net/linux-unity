#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
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
# 软件授权用户名称&组：$setup_owner/$setup_owner_group
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

	# 自定义安装
	# 参数1：安装路径
	function _setup_$soft_name_compile()
	{
		cd ${TMP_$soft_upper_short_name_EXTRA_DIR}

		# 编译模式
		./configure --prefix=${TMP_$soft_upper_short_name_SETUP_DIR}
		make -j4 && make -j4 install

		# 移动编译目录所需文件
		# mv ${TMP_$soft_upper_short_name_SETUP_NAME}.conf ${TMP_$soft_upper_short_name_SETUP_DIR}/
	}

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_custom "${TMP_$soft_upper_short_name_SETUP_DIR}" "_setup_$soft_name_compile"

	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

	# 移除源文件
	rm -rf ${TMP_$soft_upper_short_name_CURRENT_DIR}
	
    # 安装初始

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

	# 开始标准化	
    ## 还原 & 创建 & 迁移
	### 日志 - ①-1Y：存在日志文件：原路径文件放给真实路径
    soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}" "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}"
	# ### 日志 - ②-N：不存在日志文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"

	### 数据 - ①-1Y：存在数据文件：原路径文件放给真实路径
    soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}"
	# ### 数据 - ②-N：不存在数据文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"

	### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" 
	# ### CONF - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"

	# 创建链接规则（原始存在则使用）
	## 日志 - supervisor
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}/supervisor_${TMP_$soft_upper_short_name_SETUP_NAME}.log" "" "${SUPERVISOR_LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}.log"
	## 日志 - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	## 数据 - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	## CONF - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" 
	
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

	# 环境变量或软连接 /etc/profile写进函数
	echo_etc_profile "$soft_upper_name_HOME=${TMP_$soft_upper_short_name_SETUP_DIR}"
	echo_etc_profile 'PATH=$$soft_upper_name_HOME/bin:$PATH'
	echo_etc_profile 'export PATH $soft_upper_name_HOME'

    # 重新加载profile文件
	source /etc/profile
	
	# ## 授权权限，否则无法写入
	# create_user_if_not_exists $setup_owner $setup_owner_group
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}

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
	
    echo_style_wrap_text "Starting 'boot check', hold on please"
	
# 	# -- 服务配置加载
# 	tee /usr/lib/systemd/system/${TMP_$soft_upper_short_name_SETUP_NAME}.service <<-EOF
# [Unit]
# Description=$soft_upper_name Server Service
# After=network.target

# [Service]
# Type=simple
# User=$setup_owner
# WorkingDirectory=${TMP_$soft_upper_short_name_SETUP_DIR}
# Restart=on-failure
# RestartSec=5s
# ExecStart=/usr/bin/${TMP_$soft_upper_short_name_SETUP_NAME} -c /etc/${TMP_$soft_upper_short_name_SETUP_NAME}/${TMP_$soft_upper_short_name_SETUP_NAME}.ini
# LimitNOFILE=infinity
# LimitNPROC=infinity
# LimitCORE=infinity

# [Install]
# WantedBy=multi-user.target
# EOF
#
# 	# 重新加载服务配置
#     systemctl daemon-reload

    # ## 设置系统管理，开机启动
    # echo_style_text "View the 'systemctl info'↓:"
    # chkconfig ${TMP_$soft_upper_short_name_SETUP_NAME} on
	# systemctl enable ${TMP_$soft_upper_short_name_SETUP_NAME}.service
	# systemctl list-unit-files | grep ${TMP_$soft_upper_short_name_SETUP_NAME}
	
	# # 启动及状态检测
    # echo "${TMP_SPLITER2}"
    # echo_style_text "View the 'service status'↓:"
    # systemctl start ${TMP_$soft_upper_short_name_SETUP_NAME}.service

    # # 等待启动
	# exec_sleep 3 "Initing <${TMP_$soft_upper_short_name_SETUP_NAME}>, hold on please"

	# 验证安装/启动
	echo "[-]" >> logs/boot.log
	# systemctl status ${TMP_$soft_upper_short_name_SETUP_NAME}.service >> logs/boot.log
	bin/${TMP_$soft_upper_short_name_SETUP_NAME} start >> logs/boot.log
	# echo "${TMP_SPLITER3}" >> logs/boot.log
	# journalctl -u ${TMP_$soft_upper_short_name_SETUP_NAME} --no-pager >> logs/boot.log
    cat logs/boot.log

    # 打印版本
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'version'↓:"
    bin/${TMP_$soft_upper_short_name_SETUP_NAME} -v
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} -V
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} --version
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} version
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'help'↓:"
    bin/${TMP_$soft_upper_short_name_SETUP_NAME} -h
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} -H
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} --help
    # bin/${TMP_$soft_upper_short_name_SETUP_NAME} help

	# 等待执行完毕 产生端口
    echo_style_text "View the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <$soft_name> to port '${TMP_$soft_upper_short_name_SETUP_PORT}', hold on please" "lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}" 180 3
	lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'port'(<${TMP_$soft_upper_short_name_SETUP_PORT}>) to iptables:↓"
	echo_soft_port ${TMP_$soft_upper_short_name_SETUP_PORT}
    
	# 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'supervisor startup conf'↓:"
	# echo_startup_supervisor_config "${TMP_$soft_upper_short_name_SETUP_NAME}" "/usr/bin" "systemctl start ${TMP_$soft_upper_short_name_SETUP_NAME}.service" "" "999" "" "" false 0
	echo_startup_supervisor_config "${TMP_$soft_upper_short_name_SETUP_NAME}" "${TMP_$soft_upper_short_name_SETUP_DIR}" "bin/${TMP_$soft_upper_short_name_SETUP_NAME} start"

    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'web service init script'↓:"
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

    echo_style_wrap_text "Starting 'download exts', hold on please"

	return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_$soft_name()
{
    cd ${TMP_$soft_upper_short_name_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

	return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
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
	local TMP_$soft_upper_short_name_SETUP_NAME=${1}
	local TMP_$soft_upper_short_name_SETUP_DIR=${2}
    local TMP_$soft_upper_short_name_EXTRA_DIR=${3}

	## 统一编排到的路径
	local TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}
	local TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR=${CONF_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
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
	# local TMP_$soft_upper_short_name_SETUP_OFFICIAL_STABLE_VERS=$(curl -s https://www.xxx.com)
	# echo "$title_name: The newer stable version is ${TMP_$soft_upper_short_name_SETUP_OFFICIAL_STABLE_VERS}"
    # local TMP_$soft_upper_short_name_SETUP_NEWER="${TMP_$soft_upper_short_name_SETUP_OFFICIAL_STABLE_VERS}"

	# soft_setup_git "$setup_name" "https://github.com/${git_repo}" "exec_step_$soft_name"
	local TMP_$soft_upper_short_name_SETUP_NEWER="1.0.0"
	set_github_soft_releases_newer_version "TMP_$soft_upper_short_name_SETUP_NEWER" "${git_repo}"
	exec_text_printf "TMP_$soft_upper_short_name_SETUP_NEWER" "https://www.xxx.com/downloads/$setup_name-%s.tar.gz"
	# local TMP_$soft_upper_short_name_DOWN_URL_BASE="http://www.xxx.net/projects/releases/"
	# set_newer_by_url_list_link_date "TMP_$soft_upper_short_name_SETUP_NEWER" "${TMP_$soft_upper_short_name_DOWN_URL_BASE}" "$setup_name-.*.tar.gz"
	# set_newer_by_url_list_link_text "TMP_$soft_upper_short_name_SETUP_NEWER" "${TMP_$soft_upper_short_name_DOWN_URL_BASE}" "$setup_name-().tar.gz"
	# exec_text_printf "TMP_$soft_upper_short_name_SETUP_NEWER" "${TMP_$soft_upper_short_name_DOWN_URL_BASE}%s"
	# soft_cmd_check_confirm_git_action "$setup_name" "${git_repo}" "https://github.com/${git_repo}/releases/download/v%s/$setup_name_v%s_linux_amd64.zip" "0.4.0" "unzip $setup_name_v%s_linux_amd64.zip && mv pup /usr/bin/" "reinstall"
	# soft_cmd_check_upgrade_action "$setup_name" "exec_step_$soft_name" "$setup_name update $setup_name"
    soft_setup_wget "$setup_name" "${TMP_$soft_upper_short_name_SETUP_NEWER}" "exec_step_$soft_name"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "$title_name" "check_setup_$soft_name"
