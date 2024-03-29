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
#         https://www.51cto.com/article/652770.html
#------------------------------------------------
# 安装时版本：
# 依赖compose版本：2.20.0
#------------------------------------------------
# Debug：
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
# 暂不支持跨版本还原，例如安装第一次容器备份，第二次容器备份。但docker重装备份后再启动已存的镜像，将无法启动。
#------------------------------------------------
local TMP_SETUP_DOCKER_BC_PS_PORT=13000

##########################################################################################################

# 1-配置环境
function set_env_docker() {
    cd ${__DIR}

    echo_style_wrap_text "Starting 'configuare' <docker> 'install envs', hold on please"

    #对应删除
    #${SYS_SETUP_COMMAND} remove docker-ce
    #rm -rf /mountdisk/logs/docker && rm -rf /mountdisk/data/docker* && rm -rf /opt/docker && rm -rf /etc/docker && rm -rf /var/lib/docker && rm -rf /opt/.requriements_ivhed && rm -rf /mountdisk/conf/docker && rm -rf /var/run/docker && systemctl daemon-reload && systemctl disable docker.service

    return $?
}

# *-特殊备份，会嵌入在备份时执行
function special_backup_docker() {
    echo_style_wrap_text "Starting 'create' <docker> 'containers snapshop'"

    # 参数1：e75f9b427730
    # 参数2：browserless/chrome:latest
    # 参数3：/mountdisk/repo/migrate/snapshot/browserless_chrome/1670329246
    # 参数4：latest_1670329246
    function _special_backup_docker_snap_trail() {
        # 镜像ID
        # local TMP_DOCKER_SETUP_IMG_ID=$(docker container inspect ${1} | jq ".[0].Image" | grep -oP "(?<=^\").*(?=\"$)" | cut -d':' -f2)

        # 删除容器临时文件（例如：.X99-lock）
        echo "${TMP_SPLITER3}"
        echo_style_text "[View] the 'container tmp files clear -> /tmp'↓:"
        echo_style_text "[before]:"
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"
        docker_bash_channel_exec "${1}" "ls -lia" "" "" "/tmp"
        ## 前几行内容无效，如下 2>/dev/null
        #  .
        #  ..
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -a | tail -n +3 | xargs rm -rfv"
        docker_bash_channel_exec "${1}" "ls -a | tail -n +3 | xargs rm -rfv" "" "" "/tmp"
        echo_style_text "[after]:"
        # docker exec -u root -w /tmp -i ${1} sh -c "ls -lia"
        docker_bash_channel_exec "${1}" "ls -lia" "" "" "/tmp"

        # 停止容器
        echo "${TMP_SPLITER3}"
        echo_style_text "[View] the 'container status after stop command now'↓:"
        docker stop ${1}
        echo "[-]"
        docker ps -a | awk 'NR==1'
        docker ps -a | grep "^${1:0:12}"

        # # 删除容器
        # echo "${TMP_SPLITER3}"
        # echo_style_text "Starting remove 'container' <${2}>([${1}])↓:"
        # docker container rm ${1}
        # echo "${TMP_SPLITER3}"
        # echo_style_text "[View] the 'surplus containers'↓:"
        # docker ps -a

        # # 删除镜像
        # echo "${TMP_SPLITER3}"
        # echo_style_text "Starting remove 'image' <${2}>:↓"
        # docker rmi ${2}

        # echo "${TMP_SPLITER3}"
        # echo_style_text "Starting remove 'image cache' <${2}>([image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}]):"
        # rm -rf ${TMP_DOCKER_SETUP_LNK_DATA_DIR}/image/overlay2/imagedb/content/sha256/${TMP_DOCKER_SETUP_IMG_ID}

        # echo "${TMP_SPLITER3}"
        # echo_style_text "[View] the 'surplus images'↓:"
        # docker images
    }

    local TMP_DOCKER_SETUP_CTNS=$(docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v '^$')
    function _special_backup_docker_backup() {

        local _TMP_SPECIAL_BACKUP_DOCKER_DC_STATUS=$(echo_service_node_content "docker" "Active")
        if [ "${_TMP_SPECIAL_BACKUP_DOCKER_DC_STATUS}" != "active" ]; then
            echo_style_text "Starting boot 'services' of soft <docker>"
            ## systemctl list-unit-files | grep -E "docker|containerd" | cut -d' ' -f1 | grep -v '^$' | sort -r | xargs systemctl start
            local _TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST=$(systemctl list-unit-files | grep -E "docker|containerd" | cut -d' ' -f1 | grep -v '^$' | sort -r)
            echo "${_TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST}"
            echo "${_TMP_SPECIAL_BACKUP_DOCKER_SYSCTL_LIST}" | xargs systemctl start
        fi

        if [ -n "${TMP_DOCKER_SETUP_CTNS}" ]; then
            # 废弃下述两行代码，因外部函数无法调用
            # export -f docker_snap_create_action
            # docker container ls -a | cut -d' ' -f1 | grep -v "CONTAINER" | grep -v "^$" | xargs -I {} sh -c "docker_snap_create_action {} '${MIGRATE_DIR}/snapshot' '${LOCAL_TIMESTAMP}' '_special_backup_docker_snap_trail'"
            echo_style_text "Starting backup 'containers snapshot' of soft <docker>"
            echo "${TMP_DOCKER_SETUP_CTNS}" | eval "script_channel_action 'docker_snap_create_action' '${MIGRATE_DIR}/snapshot' '${LOCAL_TIMESTAMP}' '_special_backup_docker_snap_trail'"
            echo_style_text "The 'containers snapshop' of soft <docker> was backuped"
        else
            echo "ER："
            echo "${TMP_DOCKER_SETUP_CTNS}"
        fi
    }

    if [ $(echo "${TMP_DOCKER_SETUP_CTNS}" | wc -l) -gt 0 ]; then
        local TMP_DOCKER_SETUP_BACKUP_CTN_Y_N="Y"
        confirm_yn_action "TMP_DOCKER_SETUP_BACKUP_CTN_Y_N" "([special_backup_docker]) Please sure if u want to [backup] the <docker containers> to 'snapshot'" "_special_backup_docker_backup"
    fi

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_docker() {
    echo_style_wrap_text "Starting 'install' <docker>, hold on please"

    # 预先删除运行时文件
    rm -rf /run/containerd/containerd.sock

    # 安装初始
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_DIR}"
    soft_path_restore_confirm_create "${DOCKER_APP_SETUP_DIR}"

    cd ${TMP_DOCKER_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' <docker>, hold on please"

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
    soft_path_restore_confirm_create "${DOCKER_APP_LOGS_DIR}"
    ## 数据
    soft_path_restore_confirm_swap "${TMP_DOCKER_SETUP_LNK_DATA_DIR}" "/var/lib/docker"
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_APP_DATA_DIR}"
    soft_path_restore_confirm_create "${DOCKER_APP_DATA_DIR}"
    ## CONF - ①-2Y：存在配置文件：配置文件在 /etc 目录下，因为覆写，所以做不得真实目录
    soft_path_restore_confirm_create "${TMP_DOCKER_SETUP_LNK_CONF_DIR}"
    soft_path_restore_confirm_create "/etc/docker"
    soft_path_restore_confirm_create "${DOCKER_APP_CONF_DIR}"

    # 创建链接规则
    ## 日志
    path_not_exists_link "${TMP_DOCKER_SETUP_LOGS_DIR}" "" "${TMP_DOCKER_SETUP_LNK_LOGS_DIR}"
    ## 数据
    path_not_exists_link "${TMP_DOCKER_SETUP_DATA_DIR}" "" "${TMP_DOCKER_SETUP_LNK_DATA_DIR}"
    ## CONF - ①-2Y
    path_not_exists_link "${TMP_DOCKER_SETUP_CONF_DIR}" "" "${TMP_DOCKER_SETUP_LNK_CONF_DIR}"
    path_not_exists_link "${TMP_DOCKER_SETUP_LNK_CONF_DIR}/main" "" "/etc/docker"

    ## 安装不产生规格下的bin目录，所以手动还原创建
    path_not_exists_create "${TMP_DOCKER_SETUP_LNK_BIN_DIR}" "" "path_not_exists_link '${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker' '' '/usr/bin/docker'"

    # 预实验部分

    return $?
}

##########################################################################################################

# 4-设置软件
function conf_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <docker>, hold on please"

    # 开始配置，iptables为false时，容器间通讯会存在问题。但不影响安装
    ## 目录调整完重启进程(目录调整是否有效的验证点)
    if [ ! -a ${TMP_DOCKER_SETUP_LNK_CONF_DIR}/main/daemon.json ]; then
        cat >${TMP_DOCKER_SETUP_LNK_CONF_DIR}/main/daemon.json <<'EOF'
{
  "registry-mirrors": ["https://hub.docker.com/", "https://hub.daocloud.io/"],
  "insecure-registries": []
}
EOF
    fi

    ## 授权权限，否则无法写入
    ### 默认的安装有docker组，无docker用户
    create_user_if_not_exists root docker true

    ## 修改服务运行用户
    change_service_user docker docker

    chown -R docker:root ${TMP_DOCKER_SETUP_DIR}
    chown -R docker:root ${TMP_DOCKER_SETUP_LNK_LOGS_DIR}
    chown -R docker:root ${TMP_DOCKER_SETUP_LNK_DATA_DIR}
    chown -R docker:root ${TMP_DOCKER_SETUP_LNK_CONF_DIR}

    # 启动服务
    systemctl start docker.service

    # 配置私有仓库
    function _conf_docker_conf_insecure_registry() {
        # 确定是否存在私有仓库
        local TMP_DOCKER_SETUP_INSECURE_REGISTRY=""
        bind_if_input "TMP_DOCKER_SETUP_INSECURE_REGISTRY" "Please ender 'your insecure registries with protocol'"

        function _conf_docker_conf_insecure_registry_change_ref() {
            # 在本地添加仓库指向
            docker_change_insecure_registries "${1}"
        }

        docker_login_insecure_registries_action "TMP_DOCKER_SETUP_INSECURE_REGISTRY" "" "" "_conf_docker_conf_insecure_registry_change_ref"
    }

    confirm_y_action "N" "Please sure if u got 'insecure registry'" "_conf_docker_conf_insecure_registry"

    ## 创建自有内部网络
    if [ -z "$(docker network ls | awk -F' ' "{if(\$2==\"${DOCKER_NETWORK}\"){print}}")" ]; then
        local TMP_DOCKER_SETUP_NETWORK_SUBNET="172.16.0.0/16"
        bind_if_input "TMP_DOCKER_SETUP_NETWORK_SUBNET" "Please sure which subnet you want to use"
        if [ -n "${TMP_DOCKER_SETUP_NETWORK_SUBNET}" ]; then
            docker network create ${DOCKER_NETWORK} --subnet ${TMP_DOCKER_SETUP_NETWORK_SUBNET}
            docker network inspect ${DOCKER_NETWORK}

            echo_style_text "[View] echo the 'tcp port'(<22>) to iptables:↓"
            echo_soft_port "22" "${TMP_DOCKER_SETUP_NETWORK_SUBNET}" "tcp"
            echo "${TMP_SPLITER3}"
            echo_style_text "[View] echo the 'tcp port'(<10022>) to iptables:↓"
            echo_soft_port "10022" "${TMP_DOCKER_SETUP_NETWORK_SUBNET}" "tcp"
        fi
    fi

    # 记录配置完服务时的启动状态
    nohup systemctl status docker.service >logs/boot.log 2>&1 &

    return $?
}

##########################################################################################################

# 5-测试软件
function test_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 'restore' <docker> snapshot, hold on please"

    ## 1：检测启停
    systemctl stop docker.socket
    systemctl stop docker.service
    systemctl start docker

    ## 2：还原已有的docker快照
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

    ## 输出容器列表（browserless_chrome）
    local TMP_DOCKER_SETUP_IMG_NAMES=$(echo "${TMP_DOCKER_SETUP_SNAP_IMG_NAMES} ${TMP_DOCKER_SETUP_CLEAN_IMG_NAMES}" | sed 's@ @\n@g' | awk '$1=$1' | sort -rV | uniq)

    # ??? 先删除由于备份产生还原的Commit版
    # echo_style_text "[View] & remove the 'backuped data exists images'↓:"
    # docker images | awk 'NR==1'
    # docker images | grep -E "v[0-9]+SC[0-9]"
    # docker images | grep -E "v[0-9]+SC[0-9]" | awk -F' ' '{print $3}' | xargs -I {} docker rmi {}

    # 参数1：镜像名称，例 browserless/chrome
    # 参数2：镜像版本，例 latest
    # 参数3：启动命令，例 /bin/sh
    # 参数4：启动参数，例 --volume /etc/localtime:/etc/localtime:ro
    # 参数5：快照类型(还原时有效)，例 image/container/dockerfile
    # 参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
    function _docker_snap_restore_build() {
        # 镜像目录重建
        local TMP_DOCKER_SETUP_IMG_MARK_NAME="${1/\//_}"
        local TMP_DOCKER_SETUP_IMG_LOCAL_SH=${__DIR}/scripts/required/docker/${TMP_DOCKER_SETUP_IMG_MARK_NAME}.sh
        if [[ -e "${TMP_DOCKER_SETUP_IMG_LOCAL_SH}" ]]; then
            echo_style_wrap_text "Starting 'rebuild' <docker> snapshot struct, hold on please"
            cp ${TMP_DOCKER_SETUP_IMG_LOCAL_SH} ${TMP_DOCKER_SETUP_IMG_LOCAL_SH}.tmp.sh
            sed -i '/^soft_setup_basic/d' ${TMP_DOCKER_SETUP_IMG_LOCAL_SH}.tmp.sh
            source ${TMP_DOCKER_SETUP_IMG_LOCAL_SH}.tmp.sh
            boot_build_dc_${TMP_DOCKER_SETUP_IMG_MARK_NAME} "${@}"
            rm -rf ${TMP_DOCKER_SETUP_IMG_LOCAL_SH}.tmp.sh
        fi

        function _docker_snap_restore_boot_print() {
            docker images | awk 'NR==1'
            docker images | grep "^${1}" | awk -F" " "{if(\$2==\"${2}\"){print}}"
        }

        # 目录重建时变已启动，故注释
        # local TMP_DOCKER_SETUP_YN_BOOT="Y"
        # confirm_yn_action "TMP_DOCKER_SETUP_YN_BOOT" "Checked image(<${1}>:[${2}]) was restored, please 'sure' u will [boot] 'still or not'" "docker_image_boot_print" "(docker images | awk 'NR==1') && docker images | awk -F' ' '{if(\$1==\"${1}\"&&\$2==\"${2}\"){print}}'" "${@:1:4}" "" '_docker_snap_restore_boot_print'
        _docker_snap_restore_boot_print "${1}" "${2}"
    }

    items_split_action "${TMP_DOCKER_SETUP_IMG_NAMES//_//}" "docker_snap_restore_choice_action '%s' '' '_docker_snap_restore_build'"

    return $?
}

##########################################################################################################

# 6-启动软件
function boot_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    # 验证安装/启动
    ## 当前启动命令 && 等待启动
    echo_style_wrap_text "Starting 'boot' <docker>, hold on please"

    ## 设置系统管理，开机启动
    echo_style_text "[View] the 'systemctl info'↓:"
    chkconfig docker on # systemctl enable docker.service
    systemctl enable containerd.service
    systemctl enable docker.socket
    systemctl list-unit-files | grep docker

    # 启动及状态检测
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'service status'↓:"
    systemctl start docker.service

    exec_sleep 3 "Initing <docker>, hold on please"

    echo "[-]" >>logs/boot.log
    nohup systemctl status docker.service >>logs/boot.log 2>&1 &
    cat logs/boot.log

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'version'↓:"
    docker -v

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'info'↓:"
    docker info

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'network list'↓:"
    docker network ls

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'bridge inspect'↓:"
    docker inspect bridge

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'images'↓:"
    docker images

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'containers'↓:"
    docker ps -a

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'system df'↓:"
    docker system df

    # 结束
    exec_sleep 10 "Boot <docker> over, please check the setup log, this will stay [%s] secs to exit"

    return $?
}

##########################################################################################################

# 下载扩展/驱动/插件
function down_ext_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 'download' <docker> exts, hold on please"

    # 安装docker-compose
    soft_cmd_check_confirm_git_action "docker-compose" "docker/compose" "https://github.com/docker/compose/releases/download/v%s/docker-compose-$(uname -s)-$(uname -m)" "2.20.0" "mv docker-compose-$(uname -s)-$(uname -m) ${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker-compose && chmod +x ${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker-compose && ln -sf ${TMP_DOCKER_SETUP_LNK_BIN_DIR}/docker-compose /usr/local/bin/docker-compose"

    return $?
}

# 安装与配置扩展/驱动/插件
function setup_ext_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 'install' <docker> exts, hold on please"

    local TMP_DOCKER_SETUP_REQUIRED_DIR="$(cd "$(dirname ${__DIR}/${BASH_SOURCE[0]})" && pwd)"
    local TMP_DOCKER_SETUP_REQUIRED_SHS="$(cd ${TMP_DOCKER_SETUP_REQUIRED_DIR} && ls docker/*.sh)"
    items_split_action "TMP_DOCKER_SETUP_REQUIRED_SHS" "cd ${TMP_DOCKER_SETUP_REQUIRED_DIR} && source %s"

    # 新增兼容它监视正在运行的容器，如果有一个具有相同标记的新版本可用，它将拉取新映像并重新启动容器。
    # https://github.com/containrrr/watchtower

    return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_docker() {
    cd ${TMP_DOCKER_SETUP_DIR}

    echo_style_wrap_text "Starting 're-configuration' <docker>, hold on please"
    file_content_not_exists_echo "^alias di=.*" "~/.bashrc" "alias di='docker images'"
    file_content_not_exists_echo "^alias dv=.*" "~/.bashrc" "alias dv='docker volume'"
    file_content_not_exists_echo "^alias dvl=.*" "~/.bashrc" "alias dvl='docker volume ls'"
    file_content_not_exists_echo "^alias dvr=.*" "~/.bashrc" "alias dvr='docker volume rm'"
    file_content_not_exists_echo "^alias dp=.*" "~/.bashrc" "alias dp='docker ps'"
    file_content_not_exists_echo "^alias dpa=.*" "~/.bashrc" "alias dpa='docker ps -a'"
    file_content_not_exists_echo "^alias dpan=.*" "~/.bashrc" "alias dpan='docker ps -a --no-trunc'"
    file_content_not_exists_echo "^alias de=.*" "~/.bashrc" "alias de='docker exec'"
    file_content_not_exists_echo "^alias drm=.*" "~/.bashrc" "alias drm='docker rm'"
    file_content_not_exists_echo "^alias dri=.*" "~/.bashrc" "alias dri='docker rmi'"
    file_content_not_exists_echo "^alias dl=.*" "~/.bashrc" "alias dri='docker logs'"

    file_content_not_exists_echo "^alias dst=.*" "~/.bashrc" "alias dst='docker start'"
    file_content_not_exists_echo "^alias dsp=.*" "~/.bashrc" "alias dsp='docker stop'"
    file_content_not_exists_echo "^alias drs=.*" "~/.bashrc" "alias drs='docker restart'"
    source ~/.bashrc

    return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_docker() {
    # 变量覆盖特性，其它方法均可读取
    local TMP_DOCKER_SETUP_DIR=${SETUP_DIR}/docker

    # 统一编排到的路径
    local TMP_DOCKER_SETUP_LNK_BIN_DIR=${TMP_DOCKER_SETUP_DIR}/bin
    local TMP_DOCKER_SETUP_LNK_LOGS_DIR=${LOGS_DIR}/docker
    local TMP_DOCKER_SETUP_LNK_DATA_DIR=${DATA_DIR}/docker
    local TMP_DOCKER_SETUP_LNK_CONF_DIR=${CONF_DIR}/docker

    # 安装后的真实路径
    local TMP_DOCKER_SETUP_LOGS_DIR=${TMP_DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    local TMP_DOCKER_SETUP_DATA_DIR=${TMP_DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/main
    local TMP_DOCKER_SETUP_APP_DATA_DIR=${TMP_DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps
    local TMP_DOCKER_SETUP_CONF_DIR=${TMP_DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}

    set_env_docker

    setup_docker

    formal_docker

    conf_docker

    test_docker

    down_ext_docker
    setup_ext_docker

    boot_docker

    reconf_docker

    # 结束
    exec_sleep 30 "Install <docker> over, please checking the setup log, this will stay [%s] secs to exit"

    return $?
}

##########################################################################################################

# x1-下载软件
function check_setup_docker() {
    echo_style_wrap_text "Checking <docker> 'install', hold on please"

    # 重装/更新/安装
    soft_${SYS_SETUP_COMMAND}_check_upgrade_action "docker" "exec_step_docker" "yum -y update docker"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "Docker" "check_setup_docker"
