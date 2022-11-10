#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  https://www.runoob.com/docker/centos-docker-install.html
#------------------------------------------------
local TMP_DOCKER_SETUP_TEST_PS_PORT=15000

##########################################################################################################

# 1-配置环境
function set_env_docker()
{
    cd ${__DIR}

    #对应删除
    #${SYS_SETUP_COMMAND} remove docker-ce
    #rm -rf /mountdisk/logs/docker && rm -rf /mountdisk/data/docker* && rm -rf /opt/docker && rm -rf /etc/docker && rm -rf /var/lib/docker && rm -rf /opt/.requriements_ivhed && rm -rf /mountdisk/etc/docker && rm -rf /var/run/docker && systemctl daemon-reload && systemctl disable docker.service
    soft_${SYS_SETUP_COMMAND}_check_setup "yum-utils"
    if [ "${SYS_SETUP_COMMAND}" == "yum" ]; then
        # 更新包，因为过长所以暂时不放环境设置中
        ${SYS_SETUP_COMMAND} -y update
        ${SYS_SETUP_COMMAND} makecache fast
    fi

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_docker()
{
    # 预先删除运行时文件 
    rm -rf /run/containerd/containerd.sock

    # 安装
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    
    # 创建日志软链
    local TMP_DOCKER_SETUP_LNK_BIN_DIR=${TMP_DOCKER_SETUP_DIR}/bin
    local TMP_DOCKER_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/docker
    local TMP_DOCKER_SETUP_LNK_DATA_DIR=${DATA_DIR}/docker
    local TMP_DOCKER_SETUP_LOGS_DIR=${TMP_DOCKER_SETUP_DIR}/logs
    local TMP_DOCKER_SETUP_DATA_DIR=${TMP_DOCKER_SETUP_DIR}/data

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_DIR}"

    cd ${TMP_DOCKER_SETUP_DIR}
    
    # 预先初始化一次，启动后才有文件生成
    systemctl start docker.service

    # 还原 & 迁移
    soft_path_restore_confirm_swap "/var/lib/docker" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"

    # 还原 & 创建
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
    
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}" "" "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
    path_not_exists_link "${TMP_DOCKER_SETUP_DATA_DIR}" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"
    
    # 目录调整完重启进程
    systemctl restart docker.service
    
    # 安装初始
    ## 安装不产生目录，所以手动创建
    path_not_exists_create "${TMP_DOCKER_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker' '' '/usr/bin/docker'"

    # 获取一个测试的app，初始状态不产生日志(不主动pull也会拉取)
    docker pull training/webapp

    # -P :是容器内部端口随机映射到主机的端口。
    # -p : 是容器内部端口绑定到指定的主机端口。
    local _TMP_SETUP_DOCKER_TEST_PS_ID=`docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:5000 training/webapp python app.py`
    exec_sleep 10 "Booting the test image 'training/webapp' to port '${TMP_DOCKER_SETUP_TEST_PS_PORT}'，Waiting for a moment"
    local _TMP_SETUP_DOCKER_TEST_PS_PORT=`docker port ${_TMP_SETUP_DOCKER_TEST_PS_ID} | cut -d':' -f2`

    docker inspect ${_TMP_SETUP_DOCKER_TEST_PS_ID} | jq >> logs/test_image.log
    docker logs ${_TMP_SETUP_DOCKER_TEST_PS_ID}
    curl -s http://localhost:${_TMP_SETUP_DOCKER_TEST_PS_PORT}
    echo
    # docker stop ${_TMP_SETUP_DOCKER_TEST_PS_ID}

    # 删除images
    # docker rmi training/webapp

    # 删除容器
    # docker rm -f ${_TMP_SETUP_DOCKER_TEST_PS_ID}
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}/training_webapp-json.log" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}/containers/${_TMP_SETUP_DOCKER_TEST_PS_ID}/${_TMP_SETUP_DOCKER_TEST_PS_ID}-json.log"
    
    # 授权权限，否则无法写入
    create_user_if_not_exists docker docker
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_LOGS_DIR}
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_DATA_DIR}

    # 开始安装
    systemctl stop docker.service
	
	return $?
}

##########################################################################################################

# 3-设置软件
function conf_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
	
	local TMP_DOCKER_SETUP_LNK_ETC_DIR=${ATT_DIR}/docker
	local TMP_DOCKER_SETUP_ETC_DIR=${TMP_DOCKER_SETUP_DIR}/etc

	# ①-N：不存在配置文件：
	rm -rf ${TMP_DOCKER_SETUP_LNK_ETC_DIR}
	rm -rf ${TMP_DOCKER_SETUP_ETC_DIR}

	# 开始配置
	# 替换原路径链接
    path_not_exists_link "${TMP_DOCKER_SETUP_LNK_ETC_DIR}" "" "/etc/docker"
    path_not_exists_link "${TMP_DOCKER_SETUP_ETC_DIR}" "" "/etc/docker"

	return $?
}

##########################################################################################################

# 4-启动软件
function boot_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
	
	# 验证安装
    docker -v

    # 当前启动命令 && 等待启动
    chkconfig docker on
	chkconfig --list | grep docker
	echo
    echo_text_style "Starting 'docker'，Waiting for a moment"
    echo "--------------------------------------------"
    nohup systemctl start docker.service > logs/boot.log 2>&1 &
    exec_sleep 5 "Initing 'docker'，Waiting for a moment"

    cat logs/boot.log
    echo "--------------------------------------------"

	# 启动状态检测
	systemctl status docker.service
	
	# 添加系统启动命令
	systemctl enable docker.service

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_plugin_docker()
{
	return $?
}

# 安装驱动/插件
function setup_plugin_docker()
{
	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_docker()
{
	# 变量覆盖特性，其它方法均可读取
	local TMP_DOCKER_SETUP_DIR=${SETUP_DIR}/docker
    
	set_env_docker 

	setup_docker 

	conf_docker 

    # down_plugin_docker 
    # setup_plugin_docker 

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

