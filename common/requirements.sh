#!/bin/bash
#------------------------------------------------
#      Linux softs install scripts by env
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# Mark：依赖包，只初始化一次。不建议过多安装
#------------------------------------------------
function check_requriements()
{
    path_not_exists_action "${SETUP_DIR}/.requriements_ivhed" "setup_requriements"

	return $?
}

function setup_requriements()
{
    # exec_sleep_until_not_empty "wait for a moment" "lsof -i:13000" 180 3
    # change_service_user "docker" "docker"
    # echo "over" 
    # read -e TTTT
	echo_style_wrap_text "Starting init 'requriements libs'"

    if [ "${SYS_SETUP_COMMAND}" == "yum" ]; then
        yum -y update && yum makecache fast
    fi
    
    # 检测到有未挂载磁盘，默认将挂载第一个磁盘为/mountdisk，并重置变量
    if [ -n "${LSBLK_DISKS_UNMOUNT_STR}" ] && [ -z "${LSBLK_MOUNT_ROOT}" ]; then
        echo_style_wrap_text "'Checked' some disk no mount。Please step by step to create & format"
        resolve_unmount_disk "${MOUNT_ROOT}"
    else
        if [ -n "${LSBLK_MOUNT_ROOT}" ]; then
            local _TMP_RESIZE_DISK=$(df -h | awk "{if(\$6==\"${LSBLK_MOUNT_ROOT}\"){print \$1}}")
            if [ -n "${_TMP_RESIZE_DISK}" ]; then
                resize2fs ${_TMP_RESIZE_DISK}
            fi
        fi
    fi

    soft_${SYS_SETUP_COMMAND}_check_setup "epel-release"
    soft_${SYS_SETUP_COMMAND}_check_setup "vim-enhanced"
    soft_${SYS_SETUP_COMMAND}_check_setup "wget"

    #https://github.com/stedolan/jq
    #https://gitbook.curiouser.top/origin/linux-jq.html
    soft_${SYS_SETUP_COMMAND}_check_setup "jq"
    soft_${SYS_SETUP_COMMAND}_check_setup "lsof"
    soft_${SYS_SETUP_COMMAND}_check_setup "git"
    soft_${SYS_SETUP_COMMAND}_check_setup "zip"
    soft_${SYS_SETUP_COMMAND}_check_setup "unzip"
    soft_${SYS_SETUP_COMMAND}_check_setup "rsync"

    soft_cmd_check_confirm_git_action "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.9.0" "rpm -ivh gum_%s_linux_amd64.rpm"
    soft_cmd_check_confirm_git_action "pup" "ericchiang/pup" "https://github.com/ericchiang/pup/releases/download/v%s/pup_v%s_linux_amd64.zip" "0.4.0" "unzip pup_v%s_linux_amd64.zip && mv -f pup /usr/bin/"
    soft_cmd_check_confirm_git_action "yq" "mikefarah/yq" "https://github.com/mikefarah/yq/releases/download/v%s/yq_linux_amd64.tar.gz" "4.31.2" "tar -zxvf yq_linux_amd64.tar.gz && mv -f yq_linux_amd64 /usr/bin/yq"
    
    # 优先，后续会输出port（注意此处，会受文件名控制安装先后顺序。conda>docker>sealos）
    for _TMP_SETUP_REQURIEMENTS_SH_FILE in $(ls scripts/required/*.sh); do
        source ${_TMP_SETUP_REQURIEMENTS_SH_FILE}
    done

    # 优先，后续会输出port
    # source scripts/softs/supervisor.sh
    
	echo "don't remove" >> ${SETUP_DIR}/.requriements_ivhed
}

check_requriements