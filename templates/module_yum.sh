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
# 软件名称：$soft_name，例如miniconda
# 软件端口：$soft_port
# 软件大写分组与简称：$soft_upper_short_name
# 软件安装名称：$setup_name，例如conda
# 软件授权用户名称&组：$setup_owner/$setup_owner_group
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
	
	## 源模式
	cat << EOF | tee -a /etc/yum.repos.d/${TMP_$soft_upper_short_name_SETUP_NAME}.repo
[${TMP_$soft_upper_short_name_SETUP_NAME}]
name=${TMP_$soft_upper_short_name_SETUP_NAME} Repository
baseurl=
gpgkey=
gpgcheck=1
enabled=1
EOF
	
    # 重新加载服务配置
    systemctl daemon-reload

    # 安装初始
	soft_${SYS_SETUP_COMMAND}_check_setup "${TMP_$soft_upper_short_name_SETUP_NAME}"

	# 删除源文件
	rm -rf /etc/yum.repos.d/${TMP_$soft_upper_short_name_SETUP_NAME}.repo
	
	# 加源才需要清理
    yum clean all && yum makecache fast

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_DIR}"
	
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
	
    ## 还原 & 创建 & 迁移
	### 日志 - ①-1Y：存在日志文件：原路径文件放给真实路径
    soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}" "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}"
	# ### 日志 - ②-N：不存在日志文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"

	### 数据 - ①-1Y：存在数据文件：原路径文件放给真实路径
    soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}"
	# ### 数据 - ①-2Y：存在数据文件：数据文件在 /var/lib 下
	# soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "/var/lib/$soft_name"
	# ### 数据 - ②-N：不存在数据文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"

	### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" 
	# ## CONF - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    # soft_path_restore_confirm_action "/etc/$soft_name"
	# ### CONF - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}"

	# 创建链接规则（原始存在则使用）
	## 日志 - supervisor
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}/supervisor_${TMP_$soft_upper_short_name_SETUP_NAME}.log" "" "${SUPERVISOR_LOGS_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}.log"
	## 日志 - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	## 数据 - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	# ## CONF - ①-2Y
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" "" "/etc/$soft_name" 
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" "" "/etc/$soft_name"
	## CONF - ②-N
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_CONF_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}" 
	
    ## 安装不产生规格下的bin目录，所以手动还原创建
    path_not_exists_create "${TMP_$soft_upper_short_name_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_$soft_upper_short_name_SETUP_LNK_BIN_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}' '' '/usr/bin/${TMP_$soft_upper_short_name_SETUP_NAME}'"

	# 预实验部分
    # ## 目录调整完重启进程(目录调整是否有效的验证点)
    # systemctl restart $soft_name.service

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}
		
    echo_style_wrap_text "Starting 'configuration', hold on please"

	# 开始配置
    # ## 修改服务运行用户
    # change_service_user $setup_owner $setup_owner_group

	# ## 授权权限，否则无法写入
	# create_user_if_not_exists $setup_owner $setup_owner_group
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_CONF_DIR}

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
	
    echo_style_wrap_text "Starting 'boot check', hold on please"
	
	# 验证安装/启动
    ## 设置系统管理，开机启动
    echo_style_text "View the 'systemctl info'↓:"
    chkconfig ${TMP_$soft_upper_short_name_SETUP_NAME} on
	systemctl enable ${TMP_$soft_upper_short_name_SETUP_NAME}.service
	systemctl list-unit-files | grep ${TMP_$soft_upper_short_name_SETUP_NAME}
	
	# 启动及状态检测
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'service status'↓:"
    systemctl start ${TMP_$soft_upper_short_name_SETUP_NAME}.service

    # 等待启动
	exec_sleep 3 "Initing <${TMP_$soft_upper_short_name_SETUP_NAME}>, hold on please"

	# 验证安装/启动
	echo "[-]" >> logs/boot.log
	systemctl status ${TMP_$soft_upper_short_name_SETUP_NAME}.service >> logs/boot.log
	echo "${TMP_SPLITER3}" >> logs/boot.log
	journalctl -u ${TMP_$soft_upper_short_name_SETUP_NAME} --no-pager >> logs/boot.log
    cat logs/boot.log

    # 打印版本
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'version'↓:"
    ${TMP_$soft_upper_short_name_SETUP_NAME} -v
    # ${TMP_$soft_upper_short_name_SETUP_NAME} -V
    # ${TMP_$soft_upper_short_name_SETUP_NAME} --version
    # ${TMP_$soft_upper_short_name_SETUP_NAME} version
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'help'↓:"
    ${TMP_$soft_upper_short_name_SETUP_NAME} -h
    # ${TMP_$soft_upper_short_name_SETUP_NAME} -H
    # ${TMP_$soft_upper_short_name_SETUP_NAME} --help
    # ${TMP_$soft_upper_short_name_SETUP_NAME} help

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

    exec_sleep 10 "Boot <$soft_name> over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_$soft_name()
{
	return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_$soft_name()
{
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
# 参数1：软件安装名称
function exec_step_$soft_name()
{
	# 变量覆盖特性，其它方法均可读取
	## 执行传入参数
	local TMP_$soft_upper_short_name_SETUP_NAME=${1}
	local TMP_$soft_upper_short_name_SETUP_DIR=${SETUP_DIR}/${TMP_$soft_upper_short_name_SETUP_NAME}

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
	# local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/$setup_name
    # path_not_exists_action "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "exec_step_$soft_name" "$title_name was installed"

    # soft_cmd_check_upgrade_action "$setup_name" "exec_step_$soft_name" "yum -y update $setup_name"
    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "$setup_name" "exec_step_$soft_name" "yum -y update $setup_name"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "$title_name" "check_setup_$soft_name"