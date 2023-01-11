#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------

##########################################################################################################

# 1-配置环境
function set_env_nvm()
{
    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_nvm()
{
	## 直装模式
    cd ${SH_DIR}

    # 改变安装目录
    export NVM_DIR=${TMP_NVM_SETUP_DIR}
    
    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_NVM_SETUP_DIR}"

    # 开始安装
    bash ${SH_DIR}/install.sh
    
    ## NVM变量生效
	source ${TMP_NVM_SETUP_DIR}/nvm.sh

	return $?
}

# 2-x1 修改下载文件
function change_down_nvm()
{
    cd ${SH_DIR}

	return $?
}    

##########################################################################################################

# 3-规格化软件目录格式
function formal_nvm()
{
	cd ${TMP_NVM_SETUP_DIR}

	# 开始标准化	
    # 还原 & 创建 & 迁移
	## 数据
	soft_path_restore_confirm_create "${TMP_NVM_SETUP_LNK_DATA_DIR}"

	# 创建链接规则
	## 数据
	path_not_exists_link "${TMP_NVM_SETUP_DATA_DIR}" "" "${TMP_NVM_SETUP_LNK_DATA_DIR}"

	# # 预实验部分
    # ## 目录调整完重启进程(目录调整是否有效的验证点)

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_nvm()
{
	cd ${TMP_NVM_SETUP_DIR}
	
	# echo
    # echo_text_style "Configuration 'nvm', waiting for a moment"
    # echo "${TMP_SPLITER}"

	return $?
}

##########################################################################################################

# 5-测试软件
function test_nvm()
{
	# 实验部分

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_nvm()
{
	cd ${TMP_NVM_SETUP_DIR}
	
	# 验证安装/启动
    # 当前启动命令 && 等待启动
	echo
    echo "Starting 'nvm', waiting for a moment"
    echo "${TMP_SPLITER}"
	
	# 启动及状态检测
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'version↓':"
    nvm --version
	
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'current↓':"
    nvm current

    # 结束
    echo "${TMP_SPLITER2}"
    echo_text_style "Setup 'nvm' over"
    exec_sleep 10 "Boot 'nvm' over, please checking the setup log, this will stay 10 secs to exit"
	
	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_plugin_nvm()
{

	return $?
}

# 安装驱动/插件
function setup_plugin_nvm()
{
	echo
    echo_text_style "Starting install the popular 'nodejs vers' for most users, waiting for a moment"
    echo "${TMP_SPLITER}"
    echo_text_style "View the 'remote list↓':"
    nvm ls-remote --lts

    # local TMP_NVM_SETUP_MOST_USR_VER=`curl -s https://nodejs.org/en/ | grep "https://nodejs.org/dist" | awk -F'\"' '{print $2}' | awk -F'/' '{print $(NF-1)}' | awk NR==1 | sed 's@v@@'`

    # 安装特定的一些版本
    ## 稳定版
    echo "${TMP_SPLITER2}"	
	## 如果没加载到最新版，则默认使用稳定版（防止官方展示规则变动的情况）
    echo_text_style "Starting install the 'stable' version"
    nvm install stable

    ## 安装使用人数最多的版本
    echo "${TMP_SPLITER2}"	
    local TMP_NVM_SETUP_MOST_USR_VER=$(fetch_url_selector_attr 'https://nodejs.org/en/' 'a[class=home-downloadbutton]:has-text("Recommended For Most Users")' | awk NR==1 | cut -d' ' -f1)
    echo_text_style "Starting install the 'newer popular recommended for most users' version <${TMP_NVM_SETUP_MOST_USR_VER}>"
	nvm install ${TMP_NVM_SETUP_MOST_USR_VER}
    
    ## 安装上一个LTS版本（主要是最新版本与底层可能存在版本不兼容的情况，例如系统GLIBC版本达不到nodejs运行要求）
    echo "${TMP_SPLITER2}"
    local TMP_NVM_SETUP_PRE_LTS_VER=$(nvm ls | grep "lts/" | grep -oP "\K([0-9]{1,2}[.]){2}[0-9]{1,2}" | grep -v "${TMP_NVM_SETUP_MOST_USR_VER}" | sort -rV | awk NR==1)
    echo_text_style "Starting install the 'pre lts' version <${TMP_NVM_SETUP_PRE_LTS_VER}>"
    nvm install ${TMP_NVM_SETUP_PRE_LTS_VER}
    
	# 使用并指定新版本
    echo "${TMP_SPLITER2}"	
    local TMP_NVM_SETUP_STABLE_VER="${TMP_NVM_SETUP_PRE_LTS_VER}"
	set_if_empty "TMP_NVM_SETUP_STABLE_VER" "stable"
    echo_text_style "[Setting] the 'default alias' version <${TMP_NVM_SETUP_STABLE_VER}>"
	nvm use ${TMP_NVM_SETUP_STABLE_VER}
	nvm alias default ${TMP_NVM_SETUP_STABLE_VER}
    
    # local TMP_NVM_SETUP_NPM_PATH=`which npm`
	# local TMP_NVM_SETUP_NODE_PATH=`which node`

	# # 部分程序是识别 /usr/bin or /usr/local/bin 目录的，所以在此创建适配其需要的软连接
    # path_not_exists_action "/usr/bin/npm" "ln -sf ${TMP_NVM_SETUP_NPM_PATH} /usr/bin/npm" "Npm at '/usr/bin/npm' was linked"
    # path_not_exists_action "/usr/local/bin/npm" "ln -sf ${TMP_NVM_SETUP_NPM_PATH} /usr/local/bin/npm" "Npm at '/usr/local/bin/npm' was linked"

    # path_not_exists_action "/usr/bin/node" "ln -sf ${TMP_NVM_SETUP_NODE_PATH} /usr/bin/node" "Node at '/usr/bin/node' was linked"
    # path_not_exists_action "/usr/local/bin/node" "ln -sf ${TMP_NVM_SETUP_NODE_PATH} /usr/bin/node" "Node at '/usr/local/bin/node' was linked"
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "Starting install package manager tool of 'npm'"
    npm install -g npm@latest
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "Starting install package manager tool of 'cnpm'"
	npm install -g cnpm
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "Starting install package manager tool of 'yarn'"
	npm install -g yarn

    echo "${TMP_SPLITER2}"	
    echo_text_style "Starting install the tool of 'es-checker'"
	npm install -g es-checker
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'local list↓':"
	nvm ls
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'current nodejs version↓':"
	node --version
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'current nodejs v8-options/harmony↓':"
	node --v8-options | grep harmony
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'current npm version↓':"
	npm --version
    
    echo "${TMP_SPLITER2}"	
    echo_text_style "View the 'es-checker↓':"
	es-checker

	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_nvm()
{
	cd ${TMP_NVM_SETUP_DIR}
	
	echo
    echo_text_style "[Re configuration] 'nvm', waiting for a moment"
    echo "${TMP_SPLITER}"

    # 安装nrm
    echo_text_style "Starting install the tool of 'nrm'"
    npm install -g nrm
    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'nrm list↓':"
	nrm ls
    
	#* npm -------- https://registry.npmjs.org/
	#  yarn ------- https://registry.yarnpkg.com/
	#  cnpm ------- http://r.cnpmjs.org/
	#  taobao ----- https://registry.npm.taobao.org/
	#  nj --------- https://registry.nodejitsu.com/
	#  npmMirror -- https://skimdb.npmjs.com/registry/
	#  edunpm ----- http://registry.enpmjs.org/
    
    echo "${TMP_SPLITER2}"
    echo_text_style "Checking the 'quickly registry' by nrm"
    # 查找响应时间最短的源
	local TMP_NVM_SETUP_SOFT_NPM_NRM_TEST=`nrm test`
	local TMP_NVM_SETUP_SOFT_NPM_NRM_RESP_MIN=`echo "${TMP_NVM_SETUP_SOFT_NPM_NRM_TEST}" | grep -oP "(?<=\s)\d+(?=ms)" | sort -g | awk 'NR==1'`
	local TMP_NVM_SETUP_SOFT_NPM_NRM_REPO=`echo "${TMP_NVM_SETUP_SOFT_NPM_NRM_TEST}" | grep "${TMP_NVM_SETUP_SOFT_NPM_NRM_RESP_MIN}" | sed "s@-@@g" | grep -oP "(?<=\s).*(?=\s\d)" | awk '{sub("^ *","");sub(" *$","");print}' | awk 'NR==1'`

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'nrm test↓':"
	echo "${TMP_NVM_SETUP_SOFT_NPM_NRM_TEST}"

    echo "${TMP_SPLITER2}"
    echo_text_style "View the 'quickly registry↓':"
    echo_text_style "[${TMP_NVM_SETUP_SOFT_NPM_NRM_REPO}]"
    
    echo "${TMP_SPLITER2}"
    echo_text_style "Use the 'quickly registry↓':"
	nrm use ${TMP_NVM_SETUP_SOFT_NPM_NRM_REPO}

	# npm config set registry https://registry.npm.taobao.org
	# npm config set disturl https://npm.taobao.org/dist
	
	# yarn config set registry https://registry.npm.taobao.org --global
	# yarn config set disturl https://npm.taobao.org/dist --global    

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_nvm()
{
	set_env_nvm 

	setup_nvm 
	
	formal_nvm

	conf_nvm 
	
	test_nvm 

    down_plugin_nvm 
    setup_plugin_nvm 

	boot_nvm 

	reconf_nvm 

	return $?
}

##########################################################################################################

# x1-下载软件
function check_setup_nvm()
{
	# 变量覆盖特性，其它方法均可读取
	local TMP_NVM_SETUP_DIR=${SETUP_DIR}/nvm
	local TMP_NVM_CURRENT_DIR=`pwd`

	# 统一编排到的路径
	local TMP_NVM_SETUP_LNK_DATA_DIR=${DATA_DIR}/nvm

	# 安装后的真实路径（此处依据实际路径名称修改）
	local TMP_NVM_SETUP_DATA_DIR=${TMP_NVM_SETUP_DIR}/versions

    # 需提前引用出环境，才能调出命令
    path_exists_action "${NVM_PATH}" "source ${NVM_PATH}"
	soft_cmd_check_git_upgrade_action "nvm" "nvm-sh/nvm" "https://raw.githubusercontent.com/creationix/nvm/v%s/install.sh" "0.39.3" "exec_step_nvm" "nvm --version"

	source ${NVM_PATH}
read -e TTTT

	return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "Nvm" "check_setup_nvm"