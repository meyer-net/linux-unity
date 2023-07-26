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
# source scripts/softs/docker/check-chan.sh
#------------------------------------------------
# Debug：
# dpa --no-trunc | awk '{if($2~"easychen"){print $1}}' | xargs docker stop
# dpa --no-trunc | awk '{if($2~"easychen"){print $1}}' | xargs -I {} docker rm {} && rm -rf /mountdisk/data/docker/containers/{}*
# di | awk '{if($1~"easychen"){print $3}}' | xargs docker rmi
# rm -rf /opt/docker_apps/easychen_checkchan* && rm -rf /mountdisk/conf/docker_apps/easychen_checkchan* && rm -rf /mountdisk/logs/docker_apps/easychen_checkchan* && rm -rf /mountdisk/data/docker_apps/easychen_checkchan* && rm -rf /opt/docker/data/apps/easychen_checkchan* && rm -rf /opt/docker/conf/easychen_checkchan* && rm -rf /opt/docker/logs/easychen_checkchan* && rm -rf /mountdisk/repo/migrate/clean/easychen_checkchan*
# rm -rf /mountdisk/repo/backup/opt/docker_apps/easychen_checkchan* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/easychen_checkchan* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/easychen_checkchan* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/easychen_checkchan* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/easychen_checkchan* && rm -rf /mountdisk/repo/backup/opt/docker/conf/easychen_checkchan* && rm -rf /mountdisk/repo/backup/opt/docker/logs/easychen_checkchan*
# dvl | awk 'NR>1{print $2}' | xargs docker volume rm
#------------------------------------------------
# 安装标题：Check-Chan
# 镜像仓库：easychen
# 镜像名称：checkchan
# 运行命令：cc
# 镜像用户：node
# 软件端口：5900
# 软件大写分组与简称：CC
# 软件安装名称：check_chan
#------------------------------------------------
local TMP_DC_CC_DISPLAY_TITLE="Check-Chan"
local TMP_DC_CC_SETUP_IMG_FROM="easychen"
local TMP_DC_CC_SETUP_IMG_PRJT="checkchan"
local TMP_DC_CC_SETUP_IMG_REPO="${TMP_DC_CC_SETUP_IMG_FROM}/${TMP_DC_CC_SETUP_IMG_PRJT}"
local TMP_DC_CC_SETUP_IMG_USER="node"
local TMP_DC_CC_SETUP_INN_PORT1=8080
local TMP_DC_CC_SETUP_INN_PORT2=8088
local TMP_DC_CC_SETUP_INN_PORT3=5900
local TMP_DC_CC_SETUP_OPN_PORT1=1${TMP_DC_CC_SETUP_INN_PORT1}
local TMP_DC_CC_SETUP_OPN_PORT2=1${TMP_DC_CC_SETUP_INN_PORT2}
local TMP_DC_CC_SETUP_OPN_PORT3=1${TMP_DC_CC_SETUP_INN_PORT3}

##########################################################################################################

# 3-1：配置环境
function set_env_dc_check_chan() {
    echo_style_wrap_text "Starting 'configuare' <${TMP_DC_CC_SETUP_IMG_NAME}> 'install' [envs], hold on please"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 3-2：安装软件
function setup_dc_check_chan() {
    echo_style_wrap_text "Starting 'install' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

    function _setup_dc_check_chan_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'workingdir copy'↓:"

        # 拷贝应用目录
        # docker cp -a ${TMP_DC_CC_SETUP_CTN_ID}:/usr/lib/${TMP_DC_CC_SETUP_APP_MARK} ${1} >& /dev/null
        docker cp -a ${TMP_DC_CC_SETUP_CTN_ID}:${TMP_DC_CC_SETUP_CTN_WORK_DIR} ${1} >& /dev/null
                
        # 查看拷贝列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    ## 1：存在working dir
    soft_path_restore_confirm_pcreate "${TMP_DC_CC_SETUP_WORK_DIR}" "_setup_dc_check_chan_cp_source"

    cd ${TMP_DC_CC_SETUP_DIR}

    # 开始安装

    return $?
}

##########################################################################################################

# 3-3：规格化软件目录格式
function formal_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal' <${TMP_DC_CC_SETUP_IMG_NAME}> 'dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 数据
    #### /mountdisk/data/docker_apps/easychen_checkchan/imgver111111
    function _formal_dc_check_chan_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'data copy'↓:"

        # 拷贝日志目录
        # mkdir -pv ${1}
        # docker cp -a ${TMP_DC_CC_SETUP_CTN_ID}:/var/lib/${TMP_DC_CC_SETUP_APP_MARK} ${1} >& /dev/null
        docker cp -a ${TMP_DC_CC_SETUP_CTN_ID}:${TMP_DC_CC_SETUP_CTN_WORK_DIR}/${DEPLOY_DATA_MARK} ${1} >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CC_SETUP_CTN_UID}:${TMP_DC_CC_SETUP_CTN_GID} ${1}
        
        # 查看拷贝列表
        ls -lia ${1}
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_CC_SETUP_LNK_DATA_DIR}" "_formal_dc_check_chan_cp_data"

    ### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_CC_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_CC_SETUP_CTN_ID}"
    #### /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/container
    local TMP_DC_CC_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_CC_SETUP_LNK_CONF_DIR}/container"
    #### /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111
    function _formal_dc_check_chan_cp_conf() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'conf copy'↓:"

        # 拷贝配置目录
        ## /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/app
        docker cp -a ${TMP_DC_CC_SETUP_CTN_ID}:/etc/${TMP_DC_CC_SETUP_APP_MARK} ${1}/app >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CC_SETUP_CTN_UID}:${TMP_DC_CC_SETUP_CTN_GID} ${1}

        # 查看拷贝列表
        ls -lia ${1}/app
    
    #     # 移除本地配置目录(挂载)
    #     rm -rf ${TMP_DC_CC_SETUP_WORK_DIR}/${DEPLOY_CONF_MARK}
        #### /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_DC_CC_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_CC_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_CC_SETUP_LNK_CONF_DIR}" "_formal_dc_check_chan_cp_conf"
   
    ### 迁移CONF下LOGS归位
    #### [ 废弃，logs路径会被强制修改未docker root dir对应的数据目录，一旦软连接会被套出多层路径，如下（且修改无效）：
    ##### "LogPath": "/mountdisk/data/docker/containers/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22/mountdisk/logs/docker_apps/easychen_checkchan/imgver111111/container/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22-json.log"
    #### /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/container/${CTN_ID}-json.log ©&<- /mountdisk/logs/docker_apps/easychen_checkchan/imgver111111/container/${CTN_ID}-json.log
    # soft_path_restore_confirm_move "${TMP_DC_CC_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CC_SETUP_CTN_ID}-json.log" "${TMP_DC_CC_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CC_SETUP_CTN_ID}-json.log"
    #### ]

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/easychen_checkchan/imgver111111/logs -> /mountdisk/logs/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${TMP_DC_CC_SETUP_LOGS_DIR}" "" "${TMP_DC_CC_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/easychen_checkchan/imgver111111 -> /mountdisk/logs/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}" "" "${TMP_DC_CC_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/easychen_checkchan/imgver111111/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_CC_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CC_SETUP_CTN_ID}-json.log" "" "${TMP_DC_CC_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CC_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/easychen_checkchan/imgver111111/data -> /mountdisk/data/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${TMP_DC_CC_SETUP_DATA_DIR}" "" "${TMP_DC_CC_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/easychen_checkchan/imgver111111 -> /mountdisk/data/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}" "" "${TMP_DC_CC_SETUP_LNK_DATA_DIR}"
    ### CONF
    #### /opt/docker_apps/easychen_checkchan/imgver111111/conf -> /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${TMP_DC_CC_SETUP_CONF_DIR}" "" "${TMP_DC_CC_SETUP_LNK_CONF_DIR}"
    #### /opt/docker/conf/easychen_checkchan/imgver111111 -> /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}" "" "${TMP_DC_CC_SETUP_LNK_CONF_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/easychen_checkchan/imgver111111/container
    path_not_exists_link "${TMP_DC_CC_SETUP_CTN_DIR}" "" "${TMP_DC_CC_SETUP_LNK_CONF_CTN_DIR}"

    # 预实验部分        
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    docker_change_container_volume_migrate "${TMP_DC_CC_SETUP_CTN_ID}" "${TMP_DC_CC_SETUP_WORK_DIR}:${TMP_DC_CC_SETUP_CTN_WORK_DIR} ${TMP_DC_CC_SETUP_LNK_DATA_DIR}:${TMP_DC_CC_SETUP_CTN_WORK_DIR}/${DEPLOY_DATA_MARK} ${TMP_DC_CC_SETUP_LNK_CONF_DIR}/app:/etc/${TMP_DC_CC_SETUP_APP_MARK}" "" $([[ -z "${TMP_DC_CC_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    
    return $?
}

##########################################################################################################

# 3-4：设置软件
function conf_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

    # 开始配置
    # docker_bash_channel_exec "${TMP_DC_CC_SETUP_CTN_ID}" "sed -i \"s@os.tmpdir()@\'\/usr\/src\/app\'@g\" src/utils.js" "t" "root" "$work_dir"

    return $?
}

##########################################################################################################

# 3-5：测试软件
function test_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

    # 实验部分
    ## 1：检测启停
    docker container stop ${TMP_DC_CC_SETUP_CTN_ID}
    docker container start ${TMP_DC_CC_SETUP_CTN_ID}

    return $?
}

##########################################################################################################

# 3-6：启动后检测脚本
function boot_check_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

    if [ -n "${TMP_DC_CC_SETUP_CTN_PORT}" ]; then
        echo_style_text "[View] the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_CC_SETUP_CTN_PORT}
        echo

        # 授权iptables端口访问
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] echo the 'port'(<${TMP_DC_CC_SETUP_CTN_PORT}>) to iptables:↓"
        echo_soft_port "TMP_DC_CC_SETUP_OPN_PORT"
        
        # 生成web授权访问脚本
        # echo_web_service_init_scripts "check_chan${LOCAL_ID}" "check_chan${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_CC_SETUP_OPN_PORT} "${LOCAL_HOST}"
    fi
    
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'supervisor startup conf'↓:"
    # echo_startup_supervisor_config "${TMP_DC_CC_SETUP_IMG_MARK_NAME}" "${TMP_DC_CC_SETUP_DIR}" "systemctl start ${TMP_DC_CC_SETUP_IMG_MARK_NAME}.service" "" "999" "" "" false 0
    echo_startup_supervisor_config "${TMP_DC_CC_SETUP_IMG_MARK_NAME}" "${TMP_DC_CC_SETUP_DIR}" "bin/${TMP_DC_CC_SETUP_IMG_MARK_NAME} start"
    
    # 结束
    exec_sleep 10 "Boot <${TMP_DC_CC_SETUP_IMG_NAME}> over, please checking the setup log, this will stay %s secs to exit"
}

##########################################################################################################

# 3-7-1：下载扩展/驱动/插件
function down_ext_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}

    echo_style_wrap_text "Starting 'download' <${TMP_DC_CC_SETUP_IMG_NAME}> 'exts', hold on please"

    return $?
}

# 3-7-2：安装与配置扩展/驱动/插件
function setup_ext_dc_check_chan() {
    cd ${TMP_DC_CC_SETUP_DIR}

    echo_style_wrap_text "Starting 'install' <${TMP_DC_CC_SETUP_IMG_NAME}> 'exts', hold on please"

    return $?
}

##########################################################################################################

# 3-8：重新配置（有些软件安装完后需要重新配置）
function reconf_dc_check_chan()
{
    cd ${TMP_DC_CC_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' <${TMP_DC_CC_SETUP_IMG_NAME}>, hold on please"

	return $?
}

##########################################################################################################
# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_dc_check_chan() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CC_SETUP_CTN_ID="${1}"
    # local TMP_DC_CC_SETUP_PS_SID="${TMP_DC_CC_SETUP_CTN_ID:0:12}"
    local TMP_DC_CC_SETUP_CTN_PORT="${2}"
    # imgver111111/imgver111111_v1670000000
    local TMP_DC_CC_SETUP_CTN_VER="${3}"
    local TMP_DC_CC_SETUP_CTN_CMD="${4}"
    local TMP_DC_CC_SETUP_CTN_ARGS="${5}"
    local TMP_DC_CC_SETUP_CTN_WORK_DIR="$(echo "${5}" | grep -oP "(?<=--workdir\=)[^\s]+")"
    if [ -z "${TMP_DC_CC_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CC_SETUP_CTN_WORK_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${TMP_DC_CC_SETUP_CTN_ID})
    fi

    # 默认取进入时的目录
    if [ -z "${TMP_DC_CC_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CC_SETUP_CTN_WORK_DIR=$(docker_bash_channel_exec "${1}" "pwd" "" "${TMP_DC_CC_SETUP_IMG_USER}")
    fi
    
    # 获取授权用户的UID/GID
    local TMP_DC_CC_SETUP_CTN_UID=$(docker_bash_channel_exec "${1}" "id -u ${TMP_DC_CC_SETUP_IMG_USER}")
    local TMP_DC_CC_SETUP_CTN_GID=$(docker_bash_channel_exec "${1}" "id -g ${TMP_DC_CC_SETUP_IMG_USER}")

    # 软件内部标识版本（$3已返回该版本号，仅测试选择5.7.42的场景）
    local TMP_DC_CC_SETUP_SOFT_VER=$(docker_bash_channel_exec "${1}" 'cc -V | grep -oP "(?<=Distrib ).+(?=,)"')

    ## 统一编排到的路径
    local TMP_DC_CC_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}
    local TMP_DC_CC_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}
    local TMP_DC_CC_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}
    local TMP_DC_CC_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_CC_SETUP_IMG_MARK_NAME}/${TMP_DC_CC_SETUP_CTN_VER}

    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_CC_SETUP_APP_MARK="chromium"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_CC_SETUP_WORK_DIR=${TMP_DC_CC_SETUP_DIR}/${DEPLOY_WORK_MARK}
    local TMP_DC_CC_SETUP_LOGS_DIR=${TMP_DC_CC_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    local TMP_DC_CC_SETUP_DATA_DIR=${TMP_DC_CC_SETUP_DIR}/${DEPLOY_DATA_MARK}
    local TMP_DC_CC_SETUP_CONF_DIR=${TMP_DC_CC_SETUP_DIR}/${DEPLOY_CONF_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_CC_SETUP_IMG_NAME}>:[${TMP_DC_CC_SETUP_CTN_VER}]('${TMP_DC_CC_SETUP_CTN_ID}'), hold on please"

    set_env_dc_check_chan

    setup_dc_check_chan

    formal_dc_check_chan

    conf_dc_check_chan

    test_dc_check_chan

    # down_ext_dc_check_chan
    # setup_ext_dc_check_chan

    boot_check_dc_check_chan

    reconf_dc_check_chan
    
    # 结束
    exec_sleep 30 "Install <${TMP_DC_CC_SETUP_IMG_NAME}> over, please checking the setup log, this will stay %s secs to exit"

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 checkchan
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_check_chan() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CC_SETUP_IMG_NAME="${1}"
    local TMP_DC_CC_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_DC_CC_SETUP_IMG_VER="${2}"
    local TMP_DC_CC_SETUP_CTN_ARG_CMD="${3}"
    local TMP_DC_CC_SETUP_CTN_ARGS="${4}"
    local TMP_DC_CC_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_DC_CC_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_DC_CC_SETUP_IMG_NAME}>:[${TMP_DC_CC_SETUP_IMG_VER}], hold on please"

    # 设置密码
    local TMP_DC_CC_SETUP_DASH_PASSWD=$(console_input "$(rand_simple_passwd 'cc' 'dash' "${TMP_DC_CC_SETUP_IMG_VER}")" "Please sure your 'checkchan' <dash password>" "y")
    local TMP_DC_CC_SETUP_APIKEY=$(console_input "$(rand_simple_passwd 'cc' 'api' "${TMP_DC_CC_SETUP_IMG_VER}")" "Please sure your 'checkchan' <api-key>" "y")
    
    ## 标准启动参数
    # local TMP_DC_CC_SETUP_PRE_ARG_USER="--user $(id -u):$(id -g)"
    local TMP_DC_CC_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_CC_SETUP_OPN_PORT1}:${TMP_DC_CC_SETUP_INN_PORT1} -p ${TMP_DC_CC_SETUP_OPN_PORT2}:${TMP_DC_CC_SETUP_INN_PORT2} -p ${TMP_DC_CC_SETUP_OPN_PORT3}:${TMP_DC_CC_SETUP_INN_PORT3}"
    local TMP_DC_CC_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_DC_CC_SETUP_PRE_ARG_ENVS="--env=TZ=Asia/Shanghai --privileged=true --expose ${TMP_DC_CC_SETUP_INN_PORT1} --expose ${TMP_DC_CC_SETUP_INN_PORT2} --expose ${TMP_DC_CC_SETUP_INN_PORT3} --env=CKC_PASSWD=${TMP_DC_CC_SETUP_DASH_PASSWD} --env=API_KEY=${TMP_DC_CC_SETUP_APIKEY} --env=VNC=ON --env=VDEBUG=ON --env=WIN_WIDTH=1920 --env=WIN_HEIGHT=1080 --env=XVFB_WHD=1920x1080x16 --env=ERROR_IMAGE=NONE"
    local TMP_DC_CC_SETUP_PRE_ARG_MOUNTS="--volume=/etc/localtime:/etc/localtime:ro --volume=$(which jq):/usr/bin/jq --volume=$(which yq):/usr/bin/yq --volume=$(which gum):/usr/bin/gum --volume=$(which pup):/usr/bin/pup"
    local TMP_DC_CC_SETUP_PRE_ARGS="--name=${TMP_DC_CC_SETUP_IMG_MARK_NAME}_${TMP_DC_CC_SETUP_IMG_VER} ${TMP_DC_CC_SETUP_PRE_ARG_USER} ${TMP_DC_CC_SETUP_PRE_ARG_PORTS} ${TMP_DC_CC_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_DC_CC_SETUP_PRE_ARG_ENVS} ${TMP_DC_CC_SETUP_PRE_ARG_MOUNTS}"

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "[Container] 'pre' args && cmd↓:"
    echo "Args：${TMP_DC_CC_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CC_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "[Container] 'ctn' args && cmd↓:"
    echo "Args：${TMP_DC_CC_SETUP_CTN_ARGS:-None}"
    echo "Cmd：${TMP_DC_CC_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "Starting 'combine container' <${TMP_DC_CC_SETUP_IMG_NAME}>:[${TMP_DC_CC_SETUP_IMG_VER}] boot args, hold on please"
    docker_image_args_combine_bind "TMP_DC_CC_SETUP_PRE_ARGS" "TMP_DC_CC_SETUP_CTN_ARGS"
    echo_style_text "[Container] 'combine' args && cmd↓:"
    echo "Args：${TMP_DC_CC_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CC_SETUP_CTN_ARG_CMD:-None}"

    # 开始启动
    docker_image_boot_print "${TMP_DC_CC_SETUP_IMG_NAME}" "${TMP_DC_CC_SETUP_IMG_VER}" "${TMP_DC_CC_SETUP_CTN_ARG_CMD}" "${TMP_DC_CC_SETUP_PRE_ARGS}" "" "exec_step_dc_check_chan"
    
    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_check_chan() {
	# 当前路径（仅记录）
    local TMP_DC_CC_CURRENT_DIR=$(pwd)

    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_choice_upgrade_action "${TMP_DC_CC_SETUP_IMG_REPO}" "boot_build_dc_check_chan"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "${TMP_DC_CC_DISPLAY_TITLE}" "check_setup_dc_check_chan"