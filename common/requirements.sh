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
    # exec_sleep_until_not_empty "Waiting for a moment" "lsof -i:13000" 180 3
    # change_service_user "docker" "docker"
    # echo "over" 
    # read -e TTTT
	echo "Start to init ${green}requriements libs${reset}"

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

    soft_cmd_check_confirm_git_action "gum" "charmbracelet/gum" "https://github.com/charmbracelet/gum/releases/download/v%s/gum_%s_linux_amd64.rpm" "0.8.0" "rpm -ivh gum_%s_linux_amd64.rpm" "reinstall"
    soft_cmd_check_confirm_git_action "pup" "ericchiang/pup" "https://github.com/ericchiang/pup/releases/download/v%s/pup_v%s_linux_amd64.zip" "0.4.0" "unzip pup_v%s_linux_amd64.zip && mv pup /usr/bin/" "reinstall"
    
    # 优先，后续会输出port（注意此处，会受文件名控制安装先后顺序。docker>miniconda>sealos）
    # source scripts/required/*.sh
    source scripts/required/miniconda.sh

    # 优先，后续会输出port
    # source scripts/softs/supervisor.sh
    
	echo "don't remove" >> ${SETUP_DIR}/.requriements_ivhed
}

check_requriements