#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  https://www.runoob.com/docker/centos-docker-install.html
#         https://zhuanlan.zhihu.com/p/377456104
#         https://www.51cto.com/article/650560.html
#------------------------------------------------
# - 容器导入导出与镜像导入导出区别
#       export/import 操作对象（容器）：
#                             导出对象：tar文件 
#                             导入对象：镜像，镜像层数：一层
#                             通过export 和 import导出的容器形成镜像时, 该镜像只有一层
#       save/load 操作对象（镜像）：
#                             导出对象：tar文件 
#                             导入对象：镜像，镜像层数：多层
#                             通过save 和 load 导出的镜像保留了原镜像所有的层次结构, 导出时原镜像有几层, 导入的时候就还是有几层
#       说明：
#           你需要把 A 机器上的 X 容器迁移到 B 机器, 且 X 容器中有重要的数据需要随之一起迁移的, 就可以使用 export 和 import 参数来导入和导出
#
# - 导入的镜像层数（https://segmentfault.com/a/1190000042791276）
#   想导出容器, 但是还想保留层次结构怎么办?
#   导出容器, 很快就想到唯一一个可以导出容器的工具 export，但是又想保留底层镜像的层次结构, 那么 export 就不符合需求了。想想导出带层次结构的工具就只有镜像导出工具 save 了, 但是容器在镜像层之上还有一层新的数据怎么一起导出去呢?
#   这个时候就需要引入一个新的参数 commit, 用来保存容器现有的状态为一个新的镜像。
#   比如在 A 机器上运行的 X 容器是基于 TEST 这个镜像跑起来的, 那么我就可以通过 commit 参数, 将 X 容器的所有内容保存为一个新的镜像, 名字叫 私人订制 (内含一梗哦) 最后我再通过镜像导出工具 save 就可以完整的将 私人订制镜像(也就是 X容器 )导出为一个 tar 包了
#   而且包含了 X+1 层镜像, X 层是原镜像 TEST 的所有镜像层数, 1是容器 X 多的那一层可写层的镜像
# ??? 安装Portainer
#------------------------------------------------
local TMP_SETUP_DOCKER_BC_PS_PORT=13000

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

# *-特殊备份，会嵌入在备份时执行
function special_backup_docker()
{
    echo "${TMP_SPLITER2}"
    echo_text_style "Starting 'create' the 'containers snapshop' of soft <docker>"

    # 参数1：e75f9b427730
    # 参数2：browserless/chrome:latest
    # 参数3：/mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246
    # 参数4：latest_1670329246
    function _special_backup_docker_snap_trail()
    {
        # 镜像ID
        local TMP_DOCKER_SETUP_IMG_ID=$(docker container inspect ${1} | jq ".[0].Image" | grep -oP "(?<=^\").*(?=\"$)" | cut -d':' -f2)

        # 删除容器临时文件（例如：.X99-lock）
        echo "${TMP_SPLITER3}"
        echo_text_style "View the 'container tmp files clear -> /tmp'↓:"
        echo_text_style "[before]:"
        docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"
        ## 前几行内容无效，如下 2>/dev/null
        #  .
        #  ..
        docker exec -u root -w /tmp -i ${1} sh -c "ls -a | tail -n +3 | xargs rm -rfv"  
        echo_text_style "[after]:"
        docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"

        # 停止容器
        echo "${TMP_SPLITER3}"
        echo_text_style "View the 'container status after stop command now'↓:"
        docker stop ${1}
        echo "[-]"
		docker ps -a | awk 'NR==1'
        docker ps -a | grep "^${1:0:12}"
        
        # 删除容器
        echo "${TMP_SPLITER3}"
        echo_text_style "Starting remove 'container' <${2}>([${1}])↓:"
        docker container rm ${1}
        echo "${TMP_SPLITER3}"
        echo_text_style "View the 'surplus containers'↓:"
        docker ps -a
        
        # 删除镜像
        echo "${TMP_SPLITER3}"
        echo_text_style "Starting remove 'image' <${2}>:↓"
        docker rmi ${2}

        echo "${TMP_SPLITER3}"
        echo_text_style "Starting remove 'image cache' <${2}>([image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}]):"
        rm -rf ${TMP_DOCKER_SETUP_LNK_DATA_DIR}/image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}

        echo "${TMP_SPLITER3}"
        echo_text_style "View the 'surplus images'↓:"
        docker images
    }

    local TMP_DOCKER_SETUP_CTNS=$(docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$")    
    function _special_backup_docker_backup()
    {
        echo "${TMP_SPLITER2}"
        echo_text_style "Starting boot 'services' of soft <docker>"
        ## systemctl list-unit-files | grep -E "docker|containerd" | cut -d' ' -f1 | grep -v '^$' | sort -r | xargs systemctl start
        local _TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST=$(systemctl list-unit-files | grep -E "docker|containerd" | cut -d' ' -f1 | grep -v '^$' | sort -r)
        echo "${_TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST}"
        echo "${_TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST}" | xargs systemctl start
        
        # 废弃下述两行代码，因外部函数无法调用
        # export -f docker_snap_create_action
        # docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | xargs -I {} sh -c "docker_snap_create_action {} '${MIGRATE_DIR}/snapshot' '${LOCAL_TIMESTAMP}' '_special_backup_docker_snap_trail'"
        echo "${TMP_SPLITER2}"
        echo_text_style "Starting backup 'containers snapshot' of soft <docker>"
        echo "${TMP_DOCKER_SETUP_CTNS}" | eval "script_channel_action 'docker_snap_create_action' '${MIGRATE_DIR}/snapshot' '${LOCAL_TIMESTAMP}' '_special_backup_docker_snap_trail'"
        echo_text_style "The 'containers snapshop' of soft <docker> was backuped"
    }

    if [ $(echo "${TMP_DOCKER_SETUP_CTNS}" | wc -l) -gt 0 ]; then
        local TMP_DOCKER_SETUP_BACKUP_CTN_Y_N="Y"
        confirm_yn_action "TMP_DOCKER_SETUP_BACKUP_CTN_Y_N" "([special_backup_docker]) Please sure if u want to [backup] the <docker containers> to 'snapshot'" "_special_backup_docker_backup"
    fi
  
	return $?
}

##########################################################################################################

# 2-安装软件
function setup_docker()
{
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'install', hold on please"

    # 预先删除运行时文件 
    rm -rf /run/containerd/containerd.sock

    # 安装初始
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_DIR}"

	cd ${TMP_DOCKER_SETUP_DIR}
    
    # 开始安装

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}
    
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'formal dirs', hold on please"

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
    ## soft_path_restore_confirm_action "/etc/docker"
    # soft_path_restore_confirm_move "${TMP_DOCKER_SETUP_LNK_ETC_DIR}" "/etc/docker"
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_LNK_ETC_DIR}"

	# 创建链接规则
	## 日志
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}" "" "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
	# ## 数据
    path_not_exists_link "${TMP_DOCKER_SETUP_DATA_DIR}" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"
	## ETC - ①-2Y
    # path_not_exists_link "${TMP_DOCKER_SETUP_ETC_DIR}" "" "/etc/docker"
    path_not_exists_link "${TMP_DOCKER_SETUP_ETC_DIR}" "" "${TMP_DOCKER_SETUP_LNK_ETC_DIR}"
    
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
    
	echo
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'configuration' <docker>, wait for a moment"

	# 开始配置
    ## 目录调整完重启进程(目录调整是否有效的验证点)
    cat > ${TMP_DOCKER_SETUP_LNK_ETC_DIR}/daemon.json << 'EOF'
{
  "registry-mirrors": ["https://hub.docker.com/", "https://quay.io/search", "https://hub.daocloud.io/"]
}
EOF
    
    ## 授权权限，否则无法写入
    ### 默认的安装有docker组，无docker用户
    create_user_if_not_exists docker docker

    ## 修改服务运行用户
    change_service_user docker docker
    
	chown -R docker:docker ${TMP_DOCKER_SETUP_DIR}
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_LOGS_DIR}
    chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_DATA_DIR}
	chown -R docker:docker ${TMP_DOCKER_SETUP_LNK_ETC_DIR}

    # 启动服务
    systemctl start docker.service

    # 记录配置完服务时的启动状态
    nohup systemctl status docker.service > logs/boot.log 2>&1 &

	return $?
}

##########################################################################################################

# 5-测试软件
function test_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'restore' <docker> snapshot, wait for a moment"

    # 普通快照目录    
    local TMP_DOCKER_SETUP_SNAP_DIR="${MIGRATE_DIR}/snapshot"
    local TMP_DOCKER_SETUP_SNAP_IMG_NAMES=""
    if [ -a "${TMP_DOCKER_SETUP_SNAP_DIR}" ]; then
        TMP_DOCKER_SETUP_SNAP_IMG_NAMES=$(ls ${TMP_DOCKER_SETUP_SNAP_DIR})
    fi

    # 原始快照目录
    local TMP_DOCKER_SETUP_CLEAN_DIR="${MIGRATE_DIR}/clean"
    local TMP_DOCKER_SETUP_CLEAN_IMG_NAMES=""
    if [ -a "${TMP_DOCKER_SETUP_CLEAN_DIR}" ]; then
        TMP_DOCKER_SETUP_CLEAN_IMG_NAMES=$(ls ${TMP_DOCKER_SETUP_CLEAN_DIR})
    fi
    
    # 还原已有的docker快照
    ## 输出容器列表（browserless_chrome）
    local TMP_DOCKER_SETUP_IMG_NAMES=$(echo "${TMP_DOCKER_SETUP_SNAP_IMG_NAMES} ${TMP_DOCKER_SETUP_CLEAN_IMG_NAMES}" | sed 's@ @\n@g' | awk '$1=$1' | sort -rV | uniq)

    # ??? 先删除由于备份产生还原的Commit版
    # echo_text_style "View & remove the 'backuped data exists images'↓:"
    # docker images | awk 'NR==1'
    # docker images | grep -E "v[0-9]+SC[0-9]"
    # docker images | grep -E "v[0-9]+SC[0-9]" | awk -F' ' '{print $3}' | xargs -I {} docker rmi {}

    exec_split_action "${TMP_DOCKER_SETUP_IMG_NAMES//_//}" "docker_snap_restore_choice_action"

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}

	# 验证安装/启动
    ## 当前启动命令 && 等待启动
    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'boot' <docker>, wait for a moment"

    ## 设置系统管理，开机启动
    echo_text_style "View the 'systemctl info'↓:"
    chkconfig docker on # systemctl enable docker.service
	systemctl enable containerd.service
	systemctl enable docker.socket
	systemctl list-unit-files | grep docker

	# 启动及状态检测
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'service status'↓:"
    systemctl start docker.service

    exec_sleep 3 "Initing <docker>, wait for a moment"

    echo "[-]">> logs/boot.log
    nohup systemctl status docker.service >> logs/boot.log 2>&1 &

    cat logs/boot.log

    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'version'↓:"
    docker -v
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'info'↓:"
    docker info

    # 结束
    exec_sleep 10 "Boot <docker> over, please checking the setup log, this will stay 10 secs to exit"

	# 授权iptables端口访问
	# echo_soft_port ${TMP_SETUP_DOCKER_BC_PS_PORT}

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
	cd ${TMP_DOCKER_SETUP_DIR}

    echo "${TMP_SPLITER}"
    echo_text_style "Starting 'install' <docker> exts, wait for a moment"

    # # 安装测试镜像
    # soft_docker_check_upgrade_setup "browserless/chrome" "exec_step_browserless_chrome"

	# # 启动后执行脚本
    # # 参数1：启动后的进程ID
    # # 参数2：最终启动端口
    # # 参数3：最终启动命令
    # # 参数4：最终启动参数
    # function boot_check_browserless_chrome()
    # { 
    #     local TMP_SETUP_DOCKER_BC_PS_ID=${1}
    #     local TMP_SETUP_DOCKER_BC_PS_PORT=${2}
        
    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'container folder /usr/src/app'↓:"
    #     docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "ls -lia /usr/src/app/"

    #     echo "${TMP_SPLITER2}"
    #     echo_text_style "View the 'container visit'↓:"
    #     curl -s http://localhost:${TMP_SETUP_DOCKER_BC_PS_PORT}
    #     # docker stop ${TMP_SETUP_DOCKER_BC_PS_ID}

    #     # # 删除images
    #     # docker rmi browserless/chrome
        
    #     # 删除容器
    #     # docker rm -f ${TMP_SETUP_DOCKER_BC_PS_ID}
    #     # docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} /bin/sh
    #     # docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "whoami"
    #     # :
    #     # docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "whoami"

    #     # 结束
    # }

    # local TMP_SETUP_DOCKER_SNAP_BC_ARGS="-p ${TMP_SETUP_DOCKER_BC_PS_PORT}:3000 -e PREBOOT_CHROME=true -e CONNECTION_TIMEOUT=-1 -e MAX_CONCURRENT_SESSIONS=10 -e WORKSPACE_DELETE_EXPIRED=true -e WORKSPACE_EXPIRE_DAYS=7 -v /etc/localtime:/etc/localtime"
    # docker_image_boot_print "browserless/chrome" "" "" "${TMP_SETUP_DOCKER_SNAP_BC_ARGS}" "" "boot_check_browserless_chrome"
    
    local __TMP_DIR="$(cd "$(dirname ${__DIR}/${BASH_SOURCE[0]})" && pwd)"
    source ${__TMP_DIR}/docker/*.sh
    # 新增兼容它监视正在运行的容器，如果有一个具有相同标记的新版本可用，它将拉取新映像并重新启动容器。
    # https://github.com/containrrr/watchtower 

    echo_text_style "Install <docker> exts completed"

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
	set_env_docker 

	setup_docker 

	formal_docker 

	conf_docker 

	test_docker 

    down_ext_docker 
    setup_ext_docker 

	boot_docker 

	# reconf_docker 

	return $?
}

##########################################################################################################

# x1-下载软件
function check_setup_docker()
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

    # 重装/更新/安装
    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "docker" "exec_step_docker" "yum -y update docker"

	return $?
}

##########################################################################################################

#安装主体
soft_setup_basic "Docker" "check_setup_docker"