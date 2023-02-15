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
    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_$soft_name()
{
	## 源模式
	cat << EOF | tee -a /etc/yum.repos.d/$setup_name.repo
[$setup_name]
name=$setup_name Repository
baseurl=
gpgkey=
gpgcheck=1
enabled=1
EOF
	
    # 重新加载服务配置
    systemctl daemon-reload

    # 安装初始
	soft_${SYS_SETUP_COMMAND}_check_setup "$soft_name"

	# 删除源文件
	rm -rf /etc/yum.repos.d/$setup_name.repo
	
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

	# 开始标准化	    
    # # 预先初始化一次，启动后才有文件生成
    # systemctl start $soft_name.service
	
    # # 还原 & 创建 & 迁移
	# ## 日志
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	# ## 数据
	soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	# soft_path_restore_confirm_swap "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "/var/lib/$soft_name"
	# ## ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" 
	# ## ETC - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    # soft_path_restore_confirm_action "/etc/$soft_name"
	# ## ETC - ②-N：不存在配置文件：
	# soft_path_restore_confirm_create "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}"

	# # 创建链接规则
	# ## 日志
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LOGS_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}"
	# ## 数据
	path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_DATA_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}"
	# ## ETC - ①-2Y
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" "" "/etc/$soft_name" 
    # path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" "" "/etc/$soft_name"
	# path_not_exists_link "${TMP_$soft_upper_short_name_SETUP_ETC_DIR}" "" "${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}" 
	
    ## 安装不产生规格下的bin目录，所以手动还原创建
    # path_not_exists_create "${TMP_$soft_upper_short_name_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_$soft_upper_short_name_SETUP_LNK_BIN_DIR}/$setup_name' '' '/usr/bin/$setup_name'"

	# # 预实验部分
    # ## 目录调整完重启进程(目录调整是否有效的验证点)
    # systemctl restart $soft_name.service

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_$soft_name()
{
	cd ${TMP_$soft_upper_short_name_SETUP_DIR}

	echo
    echo_text_style "Configuration <$soft_name>, wait for a moment"
    echo "${TMP_SPLITER}"

	# 开始配置
    # ## 修改服务运行用户
    # change_service_user $setup_owner $setup_owner_group

	# ## 授权权限，否则无法写入
	# create_user_if_not_exists $setup_owner $setup_owner_group
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}
	# chown -R $setup_owner:$setup_owner_group ${TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR}

    # # 中止进程
    # systemctl stop $soft_name.service

	return $?
}

##########################################################################################################

# 5-测试软件
function test_$soft_name()
{
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
	echo
    echo "Starting <$soft_name>, wait for a moment"
    echo "${TMP_SPLITER}"

    ## 设置系统管理，开机启动
    echo_text_style "View the 'systemctl info'↓:"
    chkconfig $setup_name on
	systemctl enable $setup_name.service
	systemctl list-unit-files | grep $setup_name
	
	# 启动及状态检测
    systemctl start $setup_name.service
	## 等待执行完毕 产生端口
    echo_text_style "View the 'booting port'↓:"
    exec_sleep_until_not_empty "Booting soft of <$soft_name> to port '${TMP_$soft_upper_short_name_SETUP_PORT}', wait for a moment" "lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}" 180 3
	lsof -i:${TMP_$soft_upper_short_name_SETUP_PORT}

	# 授权iptables端口访问
    echo "${TMP_SPLITER2}"
    echo_text_style "Echo the 'port↓' to iptables:"
	echo_soft_port ${TMP_$soft_upper_short_name_SETUP_PORT}
    
    # systemctl reload $setup_name.service
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'service status'↓:"
    echo "[-]">> logs/boot.log
	nohup systemctl status $setup_name.service >> logs/boot.log 2>&1 &
    cat logs/boot.log
    echo "${TMP_SPLITER3}"
    cat /var/log/$setup_name/$setup_name.log
	# echo "${TMP_SPLITER3}"
	# journalctl -u $setup_name --no-pager | less

    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'version'↓:"
    $setup_name -v
	
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'info'↓:"
    $setup_name info

    # 生成web授权访问脚本
    echo "${TMP_SPLITER2}"
    echo_text_style "Echo the 'web service init script'↓:"
    #echo_web_service_init_scripts "$soft_name${LOCAL_ID}" "$soft_name${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_$soft_upper_short_name_SETUP_PORT} "${LOCAL_HOST}"

    # 结束
    echo "${TMP_SPLITER2}"
    echo_text_style "Setup <$soft_name> over"
    exec_sleep 10 "Boot <$soft_name> over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 下载扩展/驱动/插件
function down_ext_$soft_name()
{
	return $?
}

# 安装与配置扩展/驱动/插件
function setup_ext_$soft_name()
{
	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_$soft_name()
{
	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_$soft_name()
{    
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
	# 变量覆盖特性，其它方法均可读取
	local TMP_$soft_upper_short_name_SETUP_DIR=${SETUP_DIR}/$setup_name

	# 统一编排到的路径
	local TMP_$soft_upper_short_name_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/$setup_name
	local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/$setup_name
	local TMP_$soft_upper_short_name_SETUP_LNK_ETC_DIR=${ATT_DIR}/$setup_name

	# 安装后的真实路径（此处依据实际路径名称修改）
	local TMP_$soft_upper_short_name_SETUP_LOGS_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/logs
	local TMP_$soft_upper_short_name_SETUP_DATA_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/data
	local TMP_$soft_upper_short_name_SETUP_ETC_DIR=${TMP_$soft_upper_short_name_SETUP_DIR}/etc

	# local TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR=${DATA_DIR}/$setup_name
    # path_not_exists_action "${TMP_$soft_upper_short_name_SETUP_LNK_DATA_DIR}" "exec_step_$soft_name" "$title_name was installed"

    # soft_cmd_check_upgrade_action "$setup_name" "exec_step_$soft_name" "yum -y update $setup_name"
    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "$setup_name" "exec_step_$soft_name" "yum -y update $setup_name"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "$title_name" "check_setup_$soft_name"