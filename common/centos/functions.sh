#!/bin/sh
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://oshit.thiszw.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：无法复用的逻辑函数
#------------------------------------------------

function echo_title()
{
    # Make sure only root can run our script
    [[ $EUID -ne 0 ]] && echo -e "[${red}Error${reset}] This script must be run as root!" && exit 1

    # Clear deleted
    kill_deleted
    
	clear

    local _TMP_SPLITER_LEN=$((${#TMP_SPLITER}-2))
    local _TMP_ECHO_TITLE_LINE_PREFIX=`eval printf %.s'' {1..5}`

    local _TMP_ECHO_TITLE_NOTE_LINE1="${_TMP_ECHO_TITLE_LINE_PREFIX}Function unity boots of ${MAJOR_OS}.${MAJOR_VERS}"
    local _TMP_ECHO_TITLE_NOTE_LINE2="${_TMP_ECHO_TITLE_LINE_PREFIX}Copy right meyer.cheng - http://www.epudev.com"
    
    local _TMP_ECHO_TITLE_PATH_LINE1="${_TMP_ECHO_TITLE_LINE_PREFIX}Current dir: ${__DIR}"
    local _TMP_ECHO_TITLE_PATH_LINE2="${_TMP_ECHO_TITLE_LINE_PREFIX}Current file: ${__FILE}"
    local _TMP_ECHO_TITLE_PATH_LINE3="${_TMP_ECHO_TITLE_LINE_PREFIX}Current conf: ${__CONF}"

    local _TMP_ECHO_TITLE_ITEM_LINE1="${_TMP_ECHO_TITLE_LINE_PREFIX}System name: ${SYS_NAME}"
    local _TMP_ECHO_TITLE_ITEM_LINE2="${_TMP_ECHO_TITLE_LINE_PREFIX}Product name: ${SYS_PRODUCT_NAME}(${SYSTEMD_DETECT_VIRT})"
    local _TMP_ECHO_TITLE_ITEM_LINE3="${_TMP_ECHO_TITLE_LINE_PREFIX}OS version: ${MAJOR_OS}.${MAJOR_VERS}"
    local _TMP_ECHO_TITLE_ITEM_LINE4="${_TMP_ECHO_TITLE_LINE_PREFIX}Localhost: ${LOCAL_HOST}(${LOCAL_ID})"
    local _TMP_ECHO_TITLE_ITEM_LINE5="${_TMP_ECHO_TITLE_LINE_PREFIX}IpV4: ${LOCAL_IPV4}"
    local _TMP_ECHO_TITLE_ITEM_LINE6="${_TMP_ECHO_TITLE_LINE_PREFIX}IpV6: ${LOCAL_IPV6}"
    local _TMP_ECHO_TITLE_ITEM_LINE7="${_TMP_ECHO_TITLE_LINE_PREFIX}Processor: ${PROCESSOR_COUNT}"
    local _TMP_ECHO_TITLE_ITEM_LINE8="${_TMP_ECHO_TITLE_LINE_PREFIX}FreeMemory: ${MEMORY_GB_FREE}GB"
    
	function _TMP_ECHO_TITLE_FILL_FUNC() {
        local _TMP_FILL_RIGHT_TITLE_FORMAT=${1}
        local _TMP_FILL_RIGHT_STITLE_FORMAT=${2}
        local _TMP_FILL_RIGHT_ITEM_FORMAT=${3}

        fill_right "_TMP_ECHO_TITLE_NOTE_LINE1" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_TITLE_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_NOTE_LINE2" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_TITLE_FORMAT}"
        
        fill_right "_TMP_ECHO_TITLE_PATH_LINE1" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_STITLE_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_PATH_LINE2" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_STITLE_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_PATH_LINE3" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_STITLE_FORMAT}"

        fill_right "_TMP_ECHO_TITLE_ITEM_LINE1" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE2" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE3" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE4" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE5" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE6" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE7" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
        fill_right "_TMP_ECHO_TITLE_ITEM_LINE8" "" ${_TMP_SPLITER_LEN} "${_TMP_FILL_RIGHT_ITEM_FORMAT}"
    }

	function _TMP_ECHO_TITLE_NORMAL_FUNC() {
        _TMP_ECHO_TITLE_FILL_FUNC "|${green}%${reset}|" "|${green}%${reset}|" "|%|"

        echo "${TMP_SPLITER}"
        echo "${_TMP_ECHO_TITLE_NOTE_LINE1}"
        echo "${_TMP_ECHO_TITLE_NOTE_LINE2}"
        echo "${TMP_SPLITER}"
        echo "${_TMP_ECHO_TITLE_PATH_LINE1}"
        echo "${_TMP_ECHO_TITLE_PATH_LINE2}"
        echo "${_TMP_ECHO_TITLE_PATH_LINE3}"
        echo "${TMP_SPLITER}"
        
        echo "${_TMP_ECHO_TITLE_ITEM_LINE1}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE2}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE3}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE4}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE5}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE6}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE7}"
        echo "${_TMP_ECHO_TITLE_ITEM_LINE8}"
        
		return $?
	}
	
	function _TMP_ECHO_TITLE_GUM_FUNC() {	
        _TMP_ECHO_TITLE_FILL_FUNC `gum style --foreground 130 "%"` `gum style --foreground 112 "%"` '%'

        local _TMP_ECHO_TITLE_GUM_NOTE_LINE=`gum style --bold --align left "${_TMP_ECHO_TITLE_NOTE_LINE1}" "${_TMP_ECHO_TITLE_NOTE_LINE2}"`
        local _TMP_ECHO_TITLE_GUM_PATH_LINE=`gum style --align left "${_TMP_ECHO_TITLE_PATH_LINE1}" "${_TMP_ECHO_TITLE_PATH_LINE2}" "${_TMP_ECHO_TITLE_PATH_LINE3}"`
        local _TMP_ECHO_TITLE_GUM_ITEM_LINE=`gum style --align left "${_TMP_ECHO_TITLE_ITEM_LINE1}" "${_TMP_ECHO_TITLE_ITEM_LINE2}" "${_TMP_ECHO_TITLE_ITEM_LINE3}" "${_TMP_ECHO_TITLE_ITEM_LINE4}" "${_TMP_ECHO_TITLE_ITEM_LINE5}" "${_TMP_ECHO_TITLE_ITEM_LINE6}" "${_TMP_ECHO_TITLE_ITEM_LINE7}" "${_TMP_ECHO_TITLE_ITEM_LINE8}"`
        
        local _TMP_ECHO_TITLE_GUM_SPLIT_CHARS=`eval printf %.s'-' {1..$((${_TMP_SPLITER_LEN}-${#_TMP_ECHO_TITLE_LINE_PREFIX}-1))}`
        local _TMP_ECHO_TITLE_GUM_SPLIT_LINE=`gum style --strikethrough --foreground 212 "${_TMP_ECHO_TITLE_LINE_PREFIX}${_TMP_ECHO_TITLE_GUM_SPLIT_CHARS}"`
        
        gum style --border double --width $((${_TMP_SPLITER_LEN}+${#_TMP_ECHO_TITLE_LINE_PREFIX})) --padding "1 1" \
        "${_TMP_ECHO_TITLE_GUM_NOTE_LINE}" \
        "${_TMP_ECHO_TITLE_GUM_SPLIT_LINE}" \
        "${_TMP_ECHO_TITLE_GUM_PATH_LINE}" \
        "${_TMP_ECHO_TITLE_GUM_SPLIT_LINE}" \
        "${_TMP_ECHO_TITLE_GUM_ITEM_LINE}"
        
		return $?
	}
    
	path_exists_yn_action "${SETUP_DIR}/.requriements_ivhed" "_TMP_ECHO_TITLE_GUM_FUNC" "_TMP_ECHO_TITLE_NORMAL_FUNC"	

    return $?
}

#---------- BASE ---------- {
# 统一将日志指向挂载盘
function link_logs()
{
    # 先创建，避免存在有些系统存在或不存在的问题。一般存在
    mkdir -pv /logs

    local TMP_LOGS_IS_LINK=`ls -il /logs | grep "\->"`
    if [ -z "${TMP_LOGS_IS_LINK}" ]; then
        mv /logs ${LOGS_DIR}
        ln -sf ${LOGS_DIR} /logs
    fi
    
    local TMP_VARLOG_IS_LINK=`ls -il /var/log | grep "\->"`
    if [ -z "${TMP_VARLOG_IS_LINK}" ]; then
        chattr -a /var/log/messages 

        cp -ra /var/log/* ${LOGS_DIR}/
        rm -rf /var/log 
        ln -sf ${LOGS_DIR} /var/log

        chattr +a /var/log/messages 
    fi

	return $?
}

function mkdirs()
{
    # 检测到有未挂载磁盘，默认将挂载第一个磁盘为/mountdisk，并重置变量
    if [ ${#LSBLK_DISKS_STR} -gt 0 ] && [ -z "${LSBLK_MOUNT_ROOT}" ]; then
        echo_style_wrap_text "'Checked' some disk no mount。Please step by step to create & format"
        resolve_unmount_disk "${MOUNT_ROOT}"
    fi

    #path_not_exists_action "$DEFAULT_DIR" "mkdir -pv $SETUP_DIR && cp --parents -av ~/.* . && sed -i \"s@$CURRENT_USER:/.*:/bin/bash@$CURRENT_USER:$DEFAULT_DIR:/bin/bash@g\" /etc/passwd"
    path_not_exists_create "${RPMS_DIR}"
    path_not_exists_create "${REPO_DIR}"
    path_not_exists_create "${CURL_DIR}"
    # path_not_exists_create "${DOCKER_APP_SETUP_DIR}"
    path_not_exists_create "${WWW_DIR}"
    path_not_exists_create "${APP_DIR}"
    path_not_exists_create "${BOOT_DIR}"
    
    path_not_exists_create "${DATA_DIR}"
    path_not_exists_action "${LOGS_DIR}" "link_logs"

    yum makecache fast

    return $?
}

#  更新库依赖
function update_libs()
{
    #---------- CHANGE ---------- {
    hostnamectl set-hostname ${SYS_NEW_NAME}
    SYS_NAME=`hostname`
    #---------- CHANGE ---------- }
    
    mkdirs

    bash -c "yum versionlock clear"
    source common/${MAJOR_OS_LOWER}/epel.sh
    source common/${MAJOR_OS_LOWER}/libs.sh

    source common/${MAJOR_OS_LOWER}/optimize.sh

	return $?
}

function mount_unmount_disks()
{
    resolve_unmount_disk
    
	return $?
}

function gen_ngx_conf()
{
    gen_nginx_starter
    
	return $?
}

function gen_sup_conf()
{
	local _TMP_GEN_SUP_CONF_NAME="test"
    bind_if_input "_TMP_GEN_SUP_CONF_NAME" "${FUNCNAME[0]} Please ender 'the program name'"

	local _TMP_GEN_SUP_CONF_BOOT_DIR="${SETUP_DIR}"
    bind_if_input "_TMP_GEN_SUP_CONF_BOOT_DIR" "${FUNCNAME[0]} Please ender 'the program boot dir'"

	local _TMP_GEN_SUP_CONF_COMMAND=""
    bind_if_input "_TMP_GEN_SUP_CONF_COMMAND" "${FUNCNAME[0]} Please ender 'the boot command'"

	local _TMP_GEN_SUP_CONF_ENV=""
    bind_if_input "_TMP_GEN_SUP_CONF_ENV" "${FUNCNAME[0]} Please ender 'the dependency of env var'"

	local _TMP_GEN_SUP_CONF_PRIORITY=99
    bind_if_input "_TMP_GEN_SUP_CONF_PRIORITY" "${FUNCNAME[0]} Please ender 'the boot priority' of your program"

	local _TMP_GEN_SUP_CONF_SOURCE="/etc/profile"
    bind_if_input "_TMP_GEN_SUP_CONF_SOURCE" "${FUNCNAME[0]} Please ender 'the dependency of env source file'"

	local _TMP_GEN_SUP_CONF_USER="root"
    bind_if_input "_TMP_GEN_SUP_CONF_USER" "${FUNCNAME[0]} Please ender 'the boot user of your program'"

    # 授权
    create_user_if_not_exists "${_TMP_GEN_SUP_CONF_USER}" "${_TMP_GEN_SUP_CONF_USER}"
    chown -R ${_TMP_GEN_SUP_CONF_USER}:${_TMP_GEN_SUP_CONF_USER} ${_TMP_GEN_SUP_CONF_BOOT_DIR}

    # 日志转储
    if [ -d "${_TMP_GEN_SUP_CONF_BOOT_DIR}/logs" ]; then
        mv ${_TMP_GEN_SUP_CONF_BOOT_DIR}/logs ${LOGS_DIR}/${_TMP_GEN_SUP_CONF_NAME}
        ln -sf ${LOGS_DIR}/${_TMP_GEN_SUP_CONF_NAME} ${_TMP_GEN_SUP_CONF_BOOT_DIR}/logs
    fi
    
    echo_startup_config "${_TMP_GEN_SUP_CONF_NAME}" "${_TMP_GEN_SUP_CONF_BOOT_DIR}" "${_TMP_GEN_SUP_CONF_COMMAND}" "${_TMP_GEN_SUP_CONF_ENV}" ${_TMP_GEN_SUP_CONF_PRIORITY} "${_TMP_GEN_SUP_CONF_SOURCE}" "${_TMP_GEN_SUP_CONF_USER}"

	return $?
}

function share_dir()
{
    exec_if_choice "_TMP_SHARE_DIR_CHOICE_TYPE" "${FUNCNAME[0]} Please choice which share type you want to use" "...,Server,Client,Exit" "${TMP_SPLITER}" "share_dir_"

    return $?
}

function share_dir_server()
{
    local _TMP_SHARE_DIR_SVR_LCL_DIR="${PRJ_DIR}"
    bind_if_input "_TMP_SHARE_DIR_SVR_LCL_DIR" "${FUNCNAME[0]} Please ender 'the dir' which u want to share"

    local _TMP_SHARE_DIR_SVR_ALLOWS=`echo ${LOCAL_HOST} | sed "s@\.${LOCAL_ID}$@.0/24@G"`
    bind_if_input "_TMP_SHARE_DIR_SVR_ALLOWS" "${FUNCNAME[0]} Please ender 'the host network area' which u allows to share"

    local _TMP_SHARE_DIR_SVR_PERS="rw,no_root_squash"
    local _TMP_SHARE_DIR_SVR_PERS_NOTICE="${FUNCNAME[0]} Please ender 'the permissions' for ref clients(${_TMP_SHARE_DIR_SVR_ALLOWS})
    # rw：可读写的权限  \
    # ro：只读的权限  \
    # no_root_squash：登入到NFS主机的用户如果是root，该用户即拥有root权限（不添加此选项ROOT只有RO权限）  \
    # root_squash：登入NFS主机的用户如果是root，该用户权限将被限定为匿名使用者nobody  \
    # all_squash：不管登陆NFS主机的用户是何权限都会被重新设定为匿名使用者nobody  \
    # anonuid：将登入NFS主机的用户都设定成指定的user id，此ID必须存在于/etc/passwd中  \
    # anongid：同anonuid，但是变成group ID就是了  \
    # sync：资料同步写入存储器中  \
    # async：资料会先暂时存放在内存中，不会直接写入硬盘  \
    # insecure：允许从这台机器过来的非授权访问"
    bind_if_input "_TMP_SHARE_DIR_SVR_PERS" "${_TMP_SHARE_DIR_SVR_PERS_NOTICE}"

    echo "${_TMP_SHARE_DIR_SVR_LCL_DIR} ${_TMP_SHARE_DIR_SVR_ALLOWS}(${_TMP_SHARE_DIR_SVR_PERS})" >> /etc/exports
    exportfs -rv

    echo

    showmount -e localhost

    echo_soft_port 111 "${_TMP_SHARE_DIR_SVR_ALLOWS}"
    echo_soft_port 2049 "${_TMP_SHARE_DIR_SVR_ALLOWS}"

    echo
    echo "${FUNCNAME[0]} Done -> (Dir of '${_TMP_SHARE_DIR_SVR_LCL_DIR}' shared for '${_TMP_SHARE_DIR_SVR_ALLOWS}')"
    echo

    return $?
}

function share_dir_client()
{
    local _TMP_SHARE_DIR_CLT_SVR_HOST="${LOCAL_HOST}"
    bind_if_input "_TMP_SHARE_DIR_CLT_SVR_HOST" "${FUNCNAME[0]} Please ender 'the host' which u want to mount dir"
    
    showmount -e ${_TMP_SHARE_DIR_CLT_SVR_HOST}
    
    local _TMP_SHARE_DIR_CLT_SVR_DIR="${PRJ_DIR}"
    bind_if_input "_TMP_SHARE_DIR_CLT_SVR_DIR" "${FUNCNAME[0]} Please ender 'the dir' which u want to mount from '${_TMP_SHARE_DIR_CLT_SVR_HOST}'"

    local _TMP_SHARE_DIR_CLT_LCL_DIR="${HTML_DIR}"
    bind_if_input "_TMP_SHARE_DIR_CLT_LCL_DIR" "${FUNCNAME[0]} Please ender 'the dir' which u want to display on local from '${_TMP_SHARE_DIR_CLT_SVR_HOST}(${_TMP_SHARE_DIR_CLT_SVR_DIR})'"

    # mount -t nfs ${_TMP_SHARE_DIR_CLT_SVR_HOST}:${_TMP_SHARE_DIR_CLT_SVR_DIR} ${_TMP_SHARE_DIR_CLT_LCL_DIR}
    echo "${_TMP_SHARE_DIR_CLT_SVR_HOST}:${_TMP_SHARE_DIR_CLT_SVR_DIR} ${_TMP_SHARE_DIR_CLT_LCL_DIR} nfs defaults 0 0" >> /etc/fstab
    mount -a

    df -h
    
    echo
    echo "${FUNCNAME[0]} Done -> (Dir of '${_TMP_SHARE_DIR_CLT_LCL_DIR}' from '${_TMP_SHARE_DIR_CLT_SVR_HOST}(${_TMP_SHARE_DIR_CLT_SVR_DIR})')"
    echo
    
    return $?
}

# SSH 端口转发
# 参考：https://blog.51cto.com/wavework/1608937 | https://blog.csdn.net/zhouguoqionghai/article/details/81869554
function ssh_transfer()
{
    # 反向：ssh -fCNR 0.0.0.0:22000:localhost:22 root@1.1.1.1 -p 22，监听远程22000，互通本地22
    # 正向：ssh -fCNL 0.0.0.0:22000:localhost:22 root@2.2.2.2 -p 22，监听本地22000，互通远程22
    typeset -u _TMP_SSH_TRANS_TUNNEL_MODE
    local _TMP_SSH_TRANS_TUNNEL_MODE="L"
    bind_if_input "_TMP_SSH_TRANS_TUNNEL_MODE" "${FUNCNAME[0]} Please ender 'the tunnel mode(Local/L、Remote/R、Dynamic/D)'?"

    local _TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER="dynamic"
    local _TMP_SSH_TRANS_TUNNEL_MODE_NAME_OPPOSITE_LOWER="dynamic"
	case ${_TMP_SSH_TRANS_TUNNEL_MODE} in
		"L")
            _TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER="local"
            _TMP_SSH_TRANS_TUNNEL_MODE_NAME_OPPOSITE_LOWER="remote"
		;;
		"R")
            _TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER="remote"
            _TMP_SSH_TRANS_TUNNEL_MODE_NAME_OPPOSITE_LOWER="local"
		;;
		*)
        _TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER="dynamic"
	esac
        
    local _TMP_SSH_TRANS_DEST_HOST="xyz.ipssh.net"
    bind_if_input "_TMP_SSH_TRANS_DEST_HOST" "${FUNCNAME[0]} Please ender 'which dest address' you want to login on remote"
    
    local _TMP_SSH_TRANS_DEST_HOST_PORT="22"
    bind_if_input "_TMP_SSH_TRANS_DEST_HOST_PORT" "${FUNCNAME[0]} Please ender 'which port of dest(${_TMP_SSH_TRANS_DEST_HOST})' you want to login on remote"

    local _TMP_SSH_TRANS_DEST_USER="root"
    bind_if_input "_TMP_SSH_TRANS_DEST_USER" "${FUNCNAME[0]} Please ender 'which user of dest(${_TMP_SSH_TRANS_DEST_HOST})' on remote by ssh to login"

    local _TMP_SSH_TRANS_TUNNEL_HOST1="localhost" 
    bind_if_input "_TMP_SSH_TRANS_TUNNEL_HOST1" "${FUNCNAME[0]} Please ender 'which ${_TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER} address' you want to listen"
    
    local _TMP_SSH_TRANS_TUNNEL_PORT1="80"
    bind_if_input "_TMP_SSH_TRANS_TUNNEL_PORT1" "${FUNCNAME[0]} Please ender 'the port' u want to listener on ${_TMP_SSH_TRANS_TUNNEL_MODE_NAME_LOWER}"
        
    local _TMP_SSH_TRANS_TUNNEL_HOST2="localhost" 
    bind_if_input "_TMP_SSH_TRANS_TUNNEL_HOST2" "${FUNCNAME[0]} Please ender 'which ${_TMP_SSH_TRANS_TUNNEL_MODE_NAME_OPPOSITE_LOWER} address' you want to listen"
    
    local _TMP_SSH_TRANS_TUNNEL_PORT2="${_TMP_SSH_TRANS_TUNNEL_PORT1}"
    bind_if_input "_TMP_SSH_TRANS_TUNNEL_PORT2" "${FUNCNAME[0]} Please ender 'which ${_TMP_SSH_TRANS_TUNNEL_MODE_NAME_OPPOSITE_LOWER} address port' you want to listen"

    function _nopwd_login()
    {
        nopwd_login "${_TMP_SSH_TRANS_DEST_HOST}" "${_TMP_SSH_TRANS_DEST_USER}" ${_TMP_SSH_TRANS_DEST_HOST_PORT}
    }

    confirm_y_action "Y" "${FUNCNAME[0]} Please sure if u want to nopass login in '${_TMP_SSH_TRANS_DEST_USER}@${_TMP_SSH_TRANS_DEST_HOST}'" "_nopwd_login"

    # -f 后台执行ssh指令
    # -C 允许压缩数据
    # -N 不执行远程指令
    # -R 将远程主机(服务器)的某个端口转发到本地端指定机器的指定端口
    # -L 将本地机(客户机)的某个端口转发到远端指定机器的指定端口
    # -p 指定远程主机的端口
    local _TMP_SSH_TRANS_SCRIPTS="-CN${_TMP_SSH_TRANS_TUNNEL_MODE} ${_TMP_SSH_TRANS_TUNNEL_HOST1}:${_TMP_SSH_TRANS_TUNNEL_PORT1}:${_TMP_SSH_TRANS_TUNNEL_HOST2}:${_TMP_SSH_TRANS_TUNNEL_PORT2} ${_TMP_SSH_TRANS_DEST_USER}@${_TMP_SSH_TRANS_DEST_HOST} -p ${_TMP_SSH_TRANS_DEST_HOST_PORT}"
    
    ssh -f ${_TMP_SSH_TRANS_SCRIPTS}

    # 本地模式需要放开端口
    if [ "${_TMP_SSH_TRANS_TUNNEL_MODE}" == "L" ]; then
        echo_soft_port ${_TMP_SSH_TRANS_TUNNEL_PORT1} 
    fi

    if [ "${_TMP_SSH_TRANS_TUNNEL_HOST1}" == "*" ]; then
        _TMP_SSH_TRANS_TUNNEL_HOST1="ALL"
    fi

    source /etc/profile
    
    local TMP_SSH_TRANS_SUP_NAME="ssh_transfer_${_TMP_SSH_TRANS_TUNNEL_MODE}_${_TMP_SSH_TRANS_DEST_USER}_${_TMP_SSH_TRANS_DEST_HOST}_${_TMP_SSH_TRANS_TUNNEL_HOST1}_${_TMP_SSH_TRANS_TUNNEL_PORT1}_${_TMP_SSH_TRANS_TUNNEL_HOST2}_${_TMP_SSH_TRANS_TUNNEL_PORT2}"
    local TMP_SSH_TRANS_ETC_FILE="${SUPERVISOR_HOME}/etc/${TMP_SSH_TRANS_SUP_NAME}.conf"

    function _echo_startup_config()
    {
        echo_startup_config "${TMP_SSH_TRANS_SUP_NAME}" "${SUPERVISOR_HOME}/scripts" "ssh ${_TMP_SSH_TRANS_SCRIPTS}" "" 1
    }

    path_not_exists_action "${TMP_SSH_TRANS_ETC_FILE}" "_echo_startup_config"

    echo
    echo "${FUNCNAME[0]} Done -> (ssh ${_TMP_SSH_TRANS_SCRIPTS})"
    echo

	return $?
}