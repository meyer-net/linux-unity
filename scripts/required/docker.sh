#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  https://www.runoob.com/docker/centos-docker-install.html
#         https://zhuanlan.zhihu.com/p/377456104
#------------------------------------------------
local TMP_DOCKER_SETUP_TEST_PS_PORT=13000

##########################################################################################################

# 1-配置环境
function set_env_docker()
{
    cd ${__DIR}

    #对应删除
    #${SYS_SETUP_COMMAND} remove docker-ce
    #rm -rf /mountdisk/logs/docker && rm -rf /mountdisk/data/docker* && rm -rf /opt/docker && rm -rf /etc/docker && rm -rf /var/lib/docker && rm -rf /opt/.requriements_ivhed && rm -rf /mountdisk/etc/docker && rm -rf /var/run/docker && systemctl daemon-reload && systemctl disable docker.service
    
	return $?
}

##########################################################################################################

# 2-安装软件
function setup_docker()
{
    # 预先删除运行时文件 
    rm -rf /run/containerd/containerd.sock

    # 安装初始
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_DIR}"
    	
	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
    
    # 预先初始化一次，启动后才有文件生成
    systemctl start docker
    
    # 停止服务，否则运行时修改会引起未知错误
    # 不执行会出警告：
    # Warning: Stopping docker.service, but it can still be activated by:
    #     docker.socket
    systemctl stop docker.socket
    systemctl stop docker.service

    # 还原 & 创建 & 迁移
	## 日志
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
	## 数据
    soft_path_restore_confirm_swap "${TMP_DOCKER_SETUP_LNK_DATA_DIR}" "/var/lib/docker"
	## ETC - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    soft_path_restore_confirm_action "/etc/docker"

	# 创建链接规则
	## 日志
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}" "" "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
	## 数据
    path_not_exists_link "${TMP_DOCKER_SETUP_DATA_DIR}" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"
	## ETC - ①-2Y
    path_not_exists_link "${TMP_DOCKER_SETUP_LNK_ETC_DIR}" "" "/etc/docker"
    path_not_exists_link "${TMP_DOCKER_SETUP_ETC_DIR}" "" "/etc/docker"
    
    ## 安装不产生规格下的bin目录，所以手动还原创建
    path_not_exists_create "${TMP_DOCKER_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker' '' '/usr/bin/docker'"
        
	# 预实验部分
    
	return $?
}

##########################################################################################################

# 4-设置软件
function conf_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
    
	# 开始配置
    ## 目录调整完重启进程(目录调整是否有效的验证点)
    
    ## 授权权限，否则无法写入
    ### 默认的安装有docker组，无docker用户
    create_user_if_not_exists docker docker

    ## 修改服务运行用户
    change_service_user docker docker
    
	chown -R docker:docker ${TMP_DOCKER_SETUP_DIR}
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_LOGS_DIR}
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_DATA_DIR}
	chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_ETC_DIR}

    systemctl start docker.service

	return $?
}

##########################################################################################################

# 5-测试软件
function test_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
    
	# 实验部分
    local _TMP_SETUP_DOCKER_TEST_IMG_INSPECT=$(docker inspect -f {{".Id"}} browserless/chrome)
    if [ -z "${_TMP_SETUP_DOCKER_TEST_IMG_INSPECT}" ]; then
        # 获取一个测试的app，初始状态不产生日志(不主动pull也会拉取)
        docker pull browserless/chrome
    fi

    # -P :是容器内部端口随机映射到主机的端口。
    # -p : 是容器内部端口绑定到指定的主机端口。
    # docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:3000 training/webapp python app.py
    local _TMP_SETUP_DOCKER_TEST_PS_ID=$(docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:3000 --restart always -e "PREBOOT_CHROME=true" -e "CONNECTION_TIMEOUT=-1" -e "MAX_CONCURRENT_SESSIONS=10" -e "WORKSPACE_DELETE_EXPIRED=true" -e "WORKSPACE_EXPIRE_DAYS=7" browserless/chrome)
    exec_sleep 5 "Booting the test image 'browserless/chrome' to port '${TMP_DOCKER_SETUP_TEST_PS_PORT}'，Waiting for a moment"
    local _TMP_SETUP_DOCKER_TEST_PS_PORT=$(docker port ${_TMP_SETUP_DOCKER_TEST_PS_ID} | cut -d':' -f2)

    # 查看日志
    docker inspect ${_TMP_SETUP_DOCKER_TEST_PS_ID} | jq >> logs/test_image.log
    echo "--------------------------------------------"
    cat logs/test_image.log
    echo "--------------------------------------------"
    docker logs ${_TMP_SETUP_DOCKER_TEST_PS_ID}
    echo "--------------------------------------------"
    curl -s http://localhost:${_TMP_SETUP_DOCKER_TEST_PS_PORT}
    echo
    # docker stop ${_TMP_SETUP_DOCKER_TEST_PS_ID}

    # # 删除images
    # docker rmi browserless/chrome

    # 删除容器
    # docker rm -f ${_TMP_SETUP_DOCKER_TEST_PS_ID}
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}/training_webapp-json.log" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}/containers/${_TMP_SETUP_DOCKER_TEST_PS_ID}/${_TMP_SETUP_DOCKER_TEST_PS_ID}-json.log"

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}

    # 当前启动命令 && 等待启动
	echo
    echo_text_style "Starting 'docker'，waiting for a moment"
    echo "--------------------------------------------"
    # 设置系统管理，开机启动
    chkconfig docker on # systemctl enable docker.service
	systemctl enable docker.socket
	
	systemctl list-unit-files | grep docker
    echo "--------------------------------------------"

	# 启动及状态检测
    systemctl start docker.service
    nohup systemctl status docker.service >> logs/boot.log 2>&1 &

    exec_sleep 3 "Initing 'docker'，waiting for a moment"

    cat logs/boot.log

    echo "--------------------------------------------"	
	
	# 验证安装/启动
    docker -v

    # 结束
    exec_sleep 10 "Boot 'docker' over，stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 下载扩展/驱动/插件
function down_ext_docker()
{
	return $?
}

# 安装与配置扩展/驱动/插件
function setup_ext_docker()
{
	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_docker()
{
	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_docker()
{
	# 变量覆盖特性，其它方法均可读取
	local TMP_DOCKER_SETUP_DIR=${SETUP_DIR}/docker

	# 统一编排到的路径
    local TMP_DOCKER_SETUP_LNK_BIN_DIR=${TMP_DOCKER_SETUP_DIR}/bin
    local TMP_DOCKER_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/docker
    local TMP_DOCKER_SETUP_LNK_DATA_DIR=${DATA_DIR}/docker
	local TMP_DOCKER_SETUP_LNK_ETC_DIR=${ATT_DIR}/docker

	# 安装后的真实路径
    local TMP_DOCKER_SETUP_LOGS_DIR=${TMP_DOCKER_SETUP_DIR}/logs
    local TMP_DOCKER_SETUP_DATA_DIR=${TMP_DOCKER_SETUP_DIR}/data
	local TMP_DOCKER_SETUP_ETC_DIR=${TMP_DOCKER_SETUP_DIR}/etc
    
	set_env_docker 

	setup_docker 

	formal_docker 

	conf_docker 

	test_docker 

    # down_ext_docker 
    # setup_ext_docker 

	boot_docker 

	# reconf_docker 

	return $?
}

##########################################################################################################

# x1-下载软件
function check_setup_docker()
{
    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "docker" "exec_step_docker"

	return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "Docker" "check_setup_docker"

