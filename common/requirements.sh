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
    # path_not_exists_link "/opt/docker/data1" "test link create" "/mountdisk/data/docker"
    # echo "over" 
    # read -e TTTT
	echo "Start to init ${green}requriements libs${reset}"

    soft_${SYS_SETUP_COMMAND}_check_setup "vim-enhanced"
    soft_${SYS_SETUP_COMMAND}_check_setup "wget"

    #https://github.com/stedolan/jq
    #https://gitbook.curiouser.top/origin/linux-jq.html
    soft_${SYS_SETUP_COMMAND}_check_setup "jq"
    soft_${SYS_SETUP_COMMAND}_check_setup "git"
    soft_${SYS_SETUP_COMMAND}_check_setup "zip"
    soft_${SYS_SETUP_COMMAND}_check_setup "unzip"

    function _setup_requriements_gum()
    {
        local TMP_GUM_SETUP_NEWER="0.8.0"
        set_github_soft_releases_newer_version "TMP_GUM_SETUP_NEWER" "charmbracelet/gum"
        while_wget "--content-disposition https://github.com/charmbracelet/gum/releases/download/v${TMP_GUM_SETUP_NEWER}/gum_${TMP_GUM_SETUP_NEWER}_linux_amd64.rpm" "rpm -ivh gum_${TMP_GUM_SETUP_NEWER}_linux_amd64.rpm"
    }
    path_exists_confirm_action "${GUM_PATH}" "The soft of 'gum' exists, please sure u will setup the newer 'still or not'?" "_setup_requriements_gum" "" "_setup_requriements_gum"
    
    function _setup_requriements_pup()
    {
        local TMP_PUP_SETUP_NEWER="0.4.0"
        set_github_soft_releases_newer_version "TMP_PUP_SETUP_NEWER" "ericchiang/pup"
        while_wget "--content-disposition https://github.com/ericchiang/pup/releases/download/v${TMP_PUP_SETUP_NEWER}/pup_v${TMP_PUP_SETUP_NEWER}_linux_amd64.zip" "unzip pup_v${TMP_PUP_SETUP_NEWER}_linux_amd64.zip && mv pup /usr/bin/"
    }
    path_exists_confirm_action "${PUP_PATH}" "The soft of 'pup' exists, please sure u will setup the newer 'still or not'?" "_setup_requriements_pup" "" "_setup_requriements_pup"

    # 优先，后续会输出port
    source scripts/required/*.sh

    # 优先，后续会输出port
    # source scripts/softs/supervisor.sh
    
	echo "don't remove" >> ${SETUP_DIR}/.requriements_ivhed
}

check_requriements