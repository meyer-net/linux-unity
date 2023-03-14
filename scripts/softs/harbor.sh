#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装标题：Harbor
# 软件名称：harbor
# 软件端口：9100
# 软件大写名称：HARBOR
# 软件大写分组与简称：HB
# 软件安装名称：$setup_name
# 软件授权用户名称&组：$setup_owner/$setup_owner_group
# 软件GIT仓储名称：${git_repo}
#------------------------------------------------
local TMP_HB_SETUP_PORT=19100

##########################################################################################################

# 1-配置环境
function set_env_harbor()
{
    echo_style_wrap_text "Starting 'configuare install envs', hold on please"

    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_harbor()
{
    echo_style_wrap_text "Starting 'install', hold on please"

	# 自定义安装
	# 参数1：安装路径
	function _setup_harbor_move()
	{
		# 直装模式
		cd $(dirname ${TMP_HB_EXTRA_DIR})
		
		# 轻量级安装的情况下不进行安装包
		## 展开路径还原操作
		mv ${TMP_HB_EXTRA_DIR} ${TMP_HB_SETUP_DIR}
	}

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_custom "${TMP_HB_SETUP_DIR}" "_setup_harbor_move"

	cd ${TMP_HB_SETUP_DIR}

    # 安装初始

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_harbor()
{
	cd ${TMP_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs', hold on please"

	# 开始标准化
    ## 还原 & 创建 & 迁移
	### 日志 - ①-1Y：存在日志文件：原路径文件放给真实路径
    soft_path_restore_confirm_move "${TMP_HB_SETUP_LNK_LOGS_DIR}" "${TMP_HB_SETUP_LOGS_DIR}"
	# ### 日志 - ②-N：不存在日志文件：
	# soft_path_restore_confirm_create "${TMP_HB_SETUP_LNK_LOGS_DIR}"

	### 数据 - ①-1Y：存在数据文件：原路径文件放给真实路径
    soft_path_restore_confirm_swap "${TMP_HB_SETUP_LNK_DATA_DIR}" "${TMP_HB_SETUP_DATA_DIR}"
	# ### 数据 - ②-N：不存在数据文件：
	# soft_path_restore_confirm_create "${TMP_HB_SETUP_LNK_DATA_DIR}"

	### ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_HB_SETUP_LNK_ETC_DIR}" "${TMP_HB_SETUP_ETC_DIR}" 
	# ### ETC - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_HB_SETUP_LNK_ETC_DIR}"

	# 创建链接规则（原始存在则使用）
	## 日志 - supervisor
	path_not_exists_link "${TMP_HB_SETUP_LOGS_DIR}/supervisor_${TMP_HB_SETUP_NAME}.log" "" "${SUPERVISOR_LOGS_DIR}/${TMP_HB_SETUP_NAME}.log"
	## 日志 - ②-N
	path_not_exists_link "${TMP_HB_SETUP_LOGS_DIR}" "" "${TMP_HB_SETUP_LNK_LOGS_DIR}"
	## 数据 - ②-N
	path_not_exists_link "${TMP_HB_SETUP_DATA_DIR}" "" "${TMP_HB_SETUP_LNK_DATA_DIR}"
	## ETC - ②-N
	path_not_exists_link "${TMP_HB_SETUP_ETC_DIR}" "" "${TMP_HB_SETUP_LNK_ETC_DIR}" 
	
    ## 安装不产生规格下的bin目录，所以手动还原创建
    # path_not_exists_create "${TMP_HB_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_HB_SETUP_LNK_BIN_DIR}/${TMP_HB_SETUP_NAME}' '' '/usr/bin/${TMP_HB_SETUP_NAME}'"

	# 预实验部分
    ## 目录调整完重启进程(目录调整是否有效的验证点)

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_harbor()
{
	cd ${TMP_HB_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'configuration', hold on please"

	# 环境变量或软连接 /etc/profile写进函数
	echo_etc_profile "HARBOR_HOME=${TMP_HB_SETUP_DIR}"
	echo_etc_profile 'PATH=$HARBOR_HOME/bin:$PATH'
	echo_etc_profile 'export PATH HARBOR_HOME'

    # 重新加载profile文件
	source /etc/profile

	# ## 授权权限，否则无法写入
	# create_user_if_not_exists $setup_owner $setup_owner_group
	# chown -R $setup_owner:$setup_owner_group ${TMP_HB_SETUP_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_HB_SETUP_LNK_LOGS_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_HB_SETUP_LNK_DATA_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_HB_SETUP_LNK_ETC_DIR}

	## 修改配置文件

	return $?
}

##########################################################################################################

# 5-测试软件
function test_harbor()
{
    cd ${TMP_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'test', hold on please"

    # 实验部分

	return $?
}

##########################################################################################################

# 6-启动及检测运行
function boot_harbor()
{
	cd ${TMP_HB_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'boot check', hold on please"
	
# 	# -- 服务配置加载
# 	tee /usr/lib/systemd/system/${TMP_HB_SETUP_NAME}.service <<-EOF
# [Unit]
# Description=HARBOR Server Service
# After=network.target

# [Service]
# Type=simple
# User=$setup_owner
# WorkingDirectory=${TMP_HB_SETUP_DIR}
# Restart=on-failure
# RestartSec=5s
# ExecStart=/usr/bin/${TMP_HB_SETUP_NAME} -c /etc/${TMP_HB_SETUP_NAME}/${TMP_HB_SETUP_NAME}.ini
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
    # chkconfig ${TMP_HB_SETUP_NAME} on
	# systemctl enable ${TMP_HB_SETUP_NAME}.service
	# systemctl list-unit-files | grep ${TMP_HB_SETUP_NAME}
	
	# # 启动及状态检测
    # echo "${TMP_SPLITER2}"
    # echo_style_text "View the 'service status'↓:"
    # systemctl start ${TMP_HB_SETUP_NAME}.service

    # # 等待启动
	# exec_sleep 3 "Initing <${TMP_HB_SETUP_NAME}>, hold on please"

	# 验证安装/启动
	echo "[-]" >> logs/boot.log
	# systemctl status ${TMP_HB_SETUP_NAME}.service >> logs/boot.log
	bin/${TMP_HB_SETUP_NAME} start >> logs/boot.log
	# echo "${TMP_SPLITER3}" >> logs/boot.log
	# journalctl -u ${TMP_HB_SETUP_NAME} --no-pager >> logs/boot.log
    cat logs/boot.log

    # 打印版本
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'version'↓:"
    bin/${TMP_HB_SETUP_NAME} -v
    # bin/${TMP_HB_SETUP_NAME} -V
    # bin/${TMP_HB_SETUP_NAME} --version
    # bin/${TMP_HB_SETUP_NAME} version
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'help'↓:"
    bin/${TMP_HB_SETUP_NAME} -h
    # bin/${TMP_HB_SETUP_NAME} -H
    # bin/${TMP_HB_SETUP_NAME} --help
    # bin/${TMP_HB_SETUP_NAME} help

	# 等待执行完毕 产生端口
    echo_style_text "View the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <harbor> to port '${TMP_HB_SETUP_PORT}', hold on please" "lsof -i:${TMP_HB_SETUP_PORT}" 180 3
	lsof -i:${TMP_HB_SETUP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'port'(<${TMP_HB_SETUP_PORT}>) to iptables:↓"
	echo_soft_port ${TMP_HB_SETUP_PORT}
    
	# 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'supervisor startup conf'↓:"
	# echo_startup_supervisor_config "${TMP_HB_SETUP_NAME}" "/usr/bin" "systemctl start ${TMP_HB_SETUP_NAME}.service" "" "999" "" "" false 0
	echo_startup_supervisor_config "${TMP_HB_SETUP_NAME}" "${TMP_HB_SETUP_DIR}" "bin/${TMP_HB_SETUP_NAME} start"

    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_style_text "View echo the 'web service init script'↓:"
    #echo_web_service_init_scripts "harbor${LOCAL_ID}" "harbor${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_HB_SETUP_PORT} "${LOCAL_HOST}"

    # 结束
    exec_sleep 10 "Boot <harbor> over, please checking the setup log, this will stay 10 secs to exit"
	
	return $?
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_harbor()
{
    cd ${TMP_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts', hold on please"

	return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_harbor()
{
    cd ${TMP_HB_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts', hold on please"

	return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_harbor()
{
    cd ${TMP_HB_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf', hold on please"

	return $?
}

##########################################################################################################

# x2-执行步骤
# 参数1：软件安装名称
# 参数2：软件安装路径
# 参数3：软件解压路径
function exec_step_harbor()
{
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_HB_SETUP_NAME=${1}
	local TMP_HB_SETUP_DIR=${2}
    local TMP_HB_EXTRA_DIR=${3}

	## 统一编排到的路径
	local TMP_HB_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/${TMP_HB_SETUP_NAME}
	local TMP_HB_SETUP_LNK_DATA_DIR=${DATA_DIR}/${TMP_HB_SETUP_NAME}
	local TMP_HB_SETUP_LNK_ETC_DIR=${ATT_DIR}/${TMP_HB_SETUP_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
	local TMP_HB_SETUP_LOGS_DIR=${TMP_HB_SETUP_DIR}/logs
	local TMP_HB_SETUP_DATA_DIR=${TMP_HB_SETUP_DIR}/data
	local TMP_HB_SETUP_ETC_DIR=${TMP_HB_SETUP_DIR}/etc

	set_env_harbor 

	setup_harbor 
	
	formal_harbor

	conf_harbor 
	
	test_harbor 

    # down_ext_harbor 
    # setup_ext_harbor 

	boot_harbor 

	# reconf_harbor 

	return $?
}

##########################################################################################################

# x1-检测软件安装
function check_setup_harbor()
{
	# 当前路径（仅记录）
	local TMP_HB_CURRENT_DIR=$(pwd)

    # 查找及确认版本
	local TMP_HB_SETUP_NEWER="1.10.17"
	set_github_soft_releases_newer_version "TMP_HB_SETUP_NEWER" "goharbor/harbor"
	exec_text_printf "TMP_HB_SETUP_NEWER" "https://github.com/goharbor/harbor/releases/download/v%s/harbor-offline-installer-v%s.tgz"
    soft_setup_wget "harbor" "${TMP_HB_SETUP_NEWER}" "exec_step_harbor"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "Harbor" "check_setup_harbor"