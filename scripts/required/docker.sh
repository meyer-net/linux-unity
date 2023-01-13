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
#------------------------------------------------
local TMP_DOCKER_SETUP_BC_PS_PORT=13000

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
    echo_text_style "Starting create the 'containers snapshop' of soft <docker>"

    # 参数1：e75f9b427730
    # 参数2：browserless/chrome:latest
    # 参数3：/mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246
    # 参数4：1670329246
    function _special_backup_docker_snap_trail()
    {
        # 镜像ID
        local TMP_DOCKER_SETUP_IMG_ID=$(docker container inspect ${1} | jq ".[0].Image" | grep -oP "(?<=^\").*(?=\"$)" | cut -d':' -f2)

        # # 删除容器临时文件（例如：.X99-lock）
        # echo "${TMP_SPLITER3}"
        # echo_text_style "View the 'container tmp files clear -> /tmp'↓:"
        # echo_text_style "[before]"
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"
        # ## 前几行内容无效，如下 2>/dev/null
        # #  .
        # #  ..
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -a | tail -n +3 | xargs rm -rfv"  
        # echo_text_style "[after]"
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"

        # 停止容器
        echo "${TMP_SPLITER3}"
        echo_text_style "View the 'container status after stop command now'↓:"
        docker stop ${1}
        echo
        echo_text_style "[CONTAINER ID][IMAGE][COMMAND][CREATED][STATUS][PORTS][NAMES]"
        docker ps -a --no-trunc | grep "${1}"
        
        # 删除容器
        echo "${TMP_SPLITER3}"
        echo_text_style "Remove 'container' <${2}>([${1}])↓:"
        docker container rm ${1}
        echo
        echo_text_style "View the 'surplus containers'↓:"
        docker ps -a
        
        # 删除镜像
        echo "${TMP_SPLITER3}"
        echo_text_style "Remove 'image' <${2}>:↓"
        docker rmi ${2}
        echo
        echo_text_style "Remove 'image cache' <${2}>([image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}]):"
        rm -rf ${TMP_DOCKER_SETUP_LNK_DATA_DIR}/image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}
        echo_text_style "View the 'surplus images'↓:"
        docker images
    }
    
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
    docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | eval "exec_channel_action 'docker_snap_create_action' '${MIGRATE_DIR}/snapshot' '${LOCAL_TIMESTAMP}' '_special_backup_docker_snap_trail'"
    echo_text_style "The 'containers snapshop' of soft <docker> was backuped"

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
    # soft_path_restore_confirm_action "/etc/docker"
    soft_path_restore_confirm_move "${TMP_DOCKER_SETUP_LNK_ETC_DIR}" "/etc/docker"

	# 创建链接规则
	## 日志
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}" "" "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
	# ## 数据
    path_not_exists_link "${TMP_DOCKER_SETUP_DATA_DIR}" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"
	## ETC - ①-2Y
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
    
	echo
    echo_text_style "Configuration <docker>, waiting for a moment"
    echo "${TMP_SPLITER}"

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

    # 实验部分
    local TMP_DOCKER_SETUP_SNAP_DIR="${MIGRATE_DIR}/snapshot"
    local TMP_DOCKER_SETUP_SNAP_AFTER_RUN_SCRIPT=""

    # 在容器内安装缺失依赖项
    # 参数1：镜像路径名称 browserless_chrome
    # 参数2：恢复版本号   1670392779
    function _test_docker_setup_dependency()
    {
        local TMP_SETUP_DOCKER_SNAP_IMG_REL_NAME=${1}
        local TMP_SETUP_DOCKER_SNAP_VER=${2}
        local TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH=${TMP_DOCKER_SETUP_SNAP_DIR}/${TMP_SETUP_DOCKER_SNAP_IMG_REL_NAME}/${2}

        function _test_docker_setup_dependency_exec()
        {
            echo
            echo_text_style "View the 'update dependency exec'↓:"
            docker cp ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.init.depend.sh ${TMP_SETUP_DOCKER_BC_PS_ID}:/tmp
            docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "apt-get update"
            docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "sh /tmp/${TMP_SETUP_DOCKER_SNAP_VER}.init.depend.sh"
        }

        path_exists_yn_action "${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.init.depend.sh" "_test_docker_setup_dependency_exec"
    }

    ## 还原备份镜像
    function _test_docker_restore_snap()
    {
        # 输出容器列表（browserless_chrome）
		local TMP_SETUP_DOCKER_CTNS=`ls ${TMP_DOCKER_SETUP_SNAP_DIR}`

        function _test_docker_restore_snap_exec()
        {
            # /mountdisk/repo/migrate/snapshot/browserless_chrome/
            local TMP_SETUP_DOCKER_SNAP_BASE_DIR="${TMP_DOCKER_SETUP_SNAP_DIR}/${1}"
            # /mountdisk/repo/migrate/snapshot/browserless_chrome/1670392779
		    local TMP_SETUP_DOCKER_SNAP_VERS=`ls ${TMP_SETUP_DOCKER_SNAP_BASE_DIR} | sort -rV | cut -d'.' -f1 | uniq`
            local TMP_SETUP_DOCKER_SNAP_VER=`echo ${TMP_SETUP_DOCKER_SNAP_VERS} | cut -d' ' -f1`
            local TMP_SETUP_DOCKER_SNAP_LNK_NAME="${1/_//}"
            local TMP_SETUP_DOCKER_SNAP_TYPES="Image,Container,Dockerfile"
            local TMP_SETUP_DOCKER_SNAP_TYPE="Image"
            
            if [ -n "${TMP_SETUP_DOCKER_SNAP_VER}" ]; then
                set_if_choice "TMP_SETUP_DOCKER_SNAP_VER" "([special_restore_docker]) Please sure 'which version' u want to [restore] of the snapshop <${TMP_SETUP_DOCKER_SNAP_LNK_NAME}>" "${TMP_SETUP_DOCKER_SNAP_VERS}"

                ## ？？？需要增加判断，有容器未必有镜像，有镜像未必有容器
                set_if_choice "TMP_SETUP_DOCKER_SNAP_TYPE" "([special_restore_docker]) Please sure 'which type' u want to [restore] of the snapshop <${TMP_SETUP_DOCKER_SNAP_LNK_NAME}>([${TMP_SETUP_DOCKER_SNAP_VER}])" ${TMP_SETUP_DOCKER_SNAP_TYPES}
                
                local TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH="${TMP_SETUP_DOCKER_SNAP_BASE_DIR}/${TMP_SETUP_DOCKER_SNAP_VER}"
                typeset -l TMP_SETUP_DOCKER_SNAP_TYPE
                
                # CMD 是个合并解析的数组，参数多时可能存在bug
                # TMP_SETUP_DOCKER_SNAP_CMD=$(cat ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.inspect.json | jq ".[0].Config.Cmd[0]")
                TMP_SETUP_DOCKER_SNAP_CMD=$(cat ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.cmd)
                TMP_SETUP_DOCKER_SNAP_CMD=${TMP_SETUP_DOCKER_SNAP_CMD:-"/bin/sh"}

                echo_text_style "Starting restore the '${TMP_SETUP_DOCKER_SNAP_TYPE}' snapshop of <${TMP_SETUP_DOCKER_SNAP_LNK_NAME}:v${TMP_SETUP_DOCKER_SNAP_VER}> by snap"
                case ${TMP_SETUP_DOCKER_SNAP_TYPE} in
                    "container")
                        TMP_SETUP_DOCKER_SNAP_BOOT_VER="v${TMP_SETUP_DOCKER_SNAP_VER}SRC"
                        zcat ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.ctn.gz | docker import - ${TMP_SETUP_DOCKER_SNAP_LNK_NAME}:${TMP_SETUP_DOCKER_SNAP_BOOT_VER}

                        # 容器恢复丢失环境信息，故需要读取容器inspect信息
                        cat ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.inspect.ctn.json | jq ".[0].Config.Env" | xargs -I {} sh -c 'echo {} | grep "=" | sed -E "s/,$//"' > ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.ctn.env

                        # 必须指定工作目录，否则会出现（OCI，no such file or directory）
                        local _TMP_DOCKER_SNAP_CREATE_WORKING_DIR=$(cat ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.inspect.ctn.json | jq ".[0].Config.WorkingDir" | grep -oP "(?<=^\").*(?=\"$)")
                        TMP_SETUP_DOCKER_SNAP_ARGS="--workdir=${_TMP_DOCKER_SNAP_CREATE_WORKING_DIR} --env-file=${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.ctn.env"
                        
                        # 如果是容器恢复的情况下，可能因缺少依赖而导致错误
                        TMP_DOCKER_SETUP_SNAP_AFTER_RUN_SCRIPT="_test_docker_setup_dependency '${1}' '${TMP_SETUP_DOCKER_SNAP_VER}'"
                    ;;
                    "image")
                        # SRI
                        # TMP_SETUP_DOCKER_SNAP_BOOT_VER="v${TMP_SETUP_DOCKER_SNAP_VER}SRI"
                        docker load < ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.img.tar
                    ;;
                    "dockerfile")
                        # ？？？缺少有效反向构建dockefile的操作，故存在bug
                        TMP_SETUP_DOCKER_SNAP_BOOT_VER="v${TMP_SETUP_DOCKER_SNAP_VER}SRD"
                        docker build -f ${TMP_SETUP_DOCKER_SNAP_FILE_NONE_PATH}.dockerfile.yml -t ${TMP_SETUP_DOCKER_SNAP_LNK_NAME}:${TMP_SETUP_DOCKER_SNAP_BOOT_VER} .
                    ;;
                    *)
                        echo
                esac
                
                echo_text_style "The ${TMP_SETUP_DOCKER_SNAP_TYPE} snapshop of '${TMP_SETUP_DOCKER_SNAP_LNK_NAME}:${TMP_SETUP_DOCKER_SNAP_BOOT_VER}' was done"
            fi
        }

        exec_split_action "${TMP_SETUP_DOCKER_CTNS}" "_test_docker_restore_snap_exec"
    }

    ## 还原备份镜像
    function _test_docker_pull_image()
    {
        # ??? 1检测没有快照时，本地备份情况
        # ??? 2需要新增没有快照时，纯净版的检测
echo "debug"
read -e TTTT
        # 获取一个测试的app，初始状态不产生日志(不主动pull也会拉取)
        docker pull browserless/chrome
        docker inspect browserless/chrome | jq > logs/browserless_chrome/${LOCAL_TIMESTAMP}.img.inspect.json
    }

    # 容器模式启动不指定会出错（docker: Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "./start.sh": stat ./start.sh: no such file or directory: unknown.）
    local TMP_SETUP_DOCKER_SNAP_CMD=""
    local TMP_SETUP_DOCKER_SNAP_BOOT_VER="latest"
    local TMP_SETUP_DOCKER_SNAP_ARGS="-e PREBOOT_CHROME=true -e CONNECTION_TIMEOUT=-1 -e MAX_CONCURRENT_SESSIONS=10 -e WORKSPACE_DELETE_EXPIRED=true -e WORKSPACE_EXPIRE_DAYS=7 -v /etc/localtime:/etc/localtime"
    path_not_exists_create "logs/browserless_chrome"
    ## 没有创建快照的情况下，默认去找纯净备份的快照
    
    path_not_exists_action "${TMP_DOCKER_SETUP_SNAP_DIR}" "echo_text_style \"Cannot found 'snapshot dir' of [${TMP_DOCKER_SETUP_SNAP_DIR}], set val to <${MIGRATE_DIR}/clean>\" && TMP_DOCKER_SETUP_SNAP_DIR=${MIGRATE_DIR}/clean"
    echo "${TMP_DOCKER_SETUP_SNAP_DIR}"
    path_exists_yn_action "${TMP_DOCKER_SETUP_SNAP_DIR}" "_test_docker_restore_snap" "_test_docker_pull_image"

    ## 安装测试镜像 browserless/chrome
    ### 还原的情况下，进程是被启动的（有容器启动，但并非一定存在镜像）
    local TMP_SETUP_DOCKER_BC_PS_ID=$(docker ps -a --no-trunc | grep "browserless/chrome" | cut -d' ' -f1)
    if [ -z "${TMP_SETUP_DOCKER_BC_PS_ID}" ]; then
        # -P :是容器内部端口随机映射到主机的端口。
        # -p : 是容器内部端口绑定到指定的主机端口。
        echo "${TMP_SPLITER2}"
        # docker run -d -p ${TMP_DOCKER_SETUP_TEST_PS_PORT}:5000 training/webapp python app.py
        echo_text_style "Cannot find created container of <browserless/chrome>, start use args(${TMP_SETUP_DOCKER_SNAP_ARGS}) && cmd(${TMP_SETUP_DOCKER_SNAP_CMD:-"None"}) to build it"
        TMP_SETUP_DOCKER_BC_PS_ID=$(docker run -d -p ${TMP_DOCKER_SETUP_BC_PS_PORT}:3000 --restart always ${TMP_SETUP_DOCKER_SNAP_ARGS} browserless/chrome:${TMP_SETUP_DOCKER_SNAP_BOOT_VER} ${TMP_SETUP_DOCKER_SNAP_CMD})
    else
        echo_text_style "Checked the container of <browserless/chrome>('${TMP_SETUP_DOCKER_BC_PS_ID}') exists, start boot it"
        docker start ${TMP_SETUP_DOCKER_BC_PS_ID}

        # 复原后，端口可能改变
        TMP_DOCKER_SETUP_BC_PS_PORT=$(docker port ${TMP_SETUP_DOCKER_BC_PS_ID} | cut -d':' -f2 | awk 'NR==1')
    fi

    # 等待执行完毕 产生端口
    exec_sleep_until_not_empty "Booting the test container 'browserless/chrome(${TMP_SETUP_DOCKER_BC_PS_ID})' to port '${TMP_DOCKER_SETUP_BC_PS_PORT}', waiting for a moment" "lsof -i:${TMP_DOCKER_SETUP_BC_PS_PORT}" 180 3

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container time'↓:"
    docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "date"

    # 必须等待启动以后才登录执行脚本
    exec_check_action "TMP_DOCKER_SETUP_SNAP_AFTER_RUN_SCRIPT"

    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}/browserless_chrome/${LOCAL_TIMESTAMP}.json.log" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}/containers/${TMP_SETUP_DOCKER_BC_PS_ID}/${TMP_SETUP_DOCKER_BC_PS_ID}-json.log"
    
    # 查看日志（config/image）
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container inspect'↓:"
    docker container inspect ${TMP_SETUP_DOCKER_BC_PS_ID} | jq > logs/browserless_chrome/${LOCAL_TIMESTAMP}.ctn.inspect.json
    cat logs/browserless_chrome/${LOCAL_TIMESTAMP}.ctn.inspect.json
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container logs'↓:"
    docker logs ${TMP_SETUP_DOCKER_BC_PS_ID}
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container visit'↓:"
    curl -s http://localhost:${TMP_DOCKER_SETUP_BC_PS_PORT}
    # docker stop ${TMP_SETUP_DOCKER_BC_PS_ID}

    # # 删除images
    # docker rmi browserless/chrome
    
    # 删除容器
    # docker rm -f ${TMP_SETUP_DOCKER_BC_PS_ID}
    # docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} /bin/sh
    # docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "whoami"
    # :
    # docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "whoami"
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container folder /tmp'↓:"
    docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "ls -lia /tmp/"

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container occupancy rate'↓:"
    docker exec -u root -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "ls / | grep -v 'proc' | xargs -I {} du -sh /{}"

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container folder /usr/src/app'↓:"
    docker exec -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "ls -lia /usr/src/app/"

    # 备份当前容器，仅在第一次 	
    local TMP_DOCKER_SETUP_CTN_CLEAN_DIR="${MIGRATE_DIR}/clean"
    path_not_exists_action "${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}/browserless_chrome" "echo '${TMP_SPLITER2}' && docker_snap_create_action '${TMP_SETUP_DOCKER_BC_PS_ID}' '${TMP_DOCKER_SETUP_CTN_CLEAN_DIR}' '${LOCAL_TIMESTAMP}'"

    # 最后更新一次容器内包
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'container update'↓:"
    docker exec -u root -w /tmp -it ${TMP_SETUP_DOCKER_BC_PS_ID} sh -c "apt-get update"

    # 结束
    echo "${TMP_SPLITER2}"

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_docker()
{
	cd ${TMP_DOCKER_SETUP_DIR}

	# 验证安装/启动
    ## 当前启动命令 && 等待启动
	echo
    echo_text_style "Starting <docker>, waiting for a moment"
    echo "${TMP_SPLITER}"

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

    exec_sleep 3 "Initing <docker>, waiting for a moment"

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
	# echo_soft_port ${TMP_DOCKER_SETUP_BC_PS_PORT}

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

    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "docker" "exec_step_docker" "yum -y update docker"

	return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "Docker" "check_setup_docker"