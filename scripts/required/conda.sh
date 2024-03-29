#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#         官方：https://docs.conda.io/
#		  安装：https://www.quanxiaoha.com/conda/linux-install-conda.html
#         附加二进制相关：https://jingyan.baidu.com/article/19192ad8df4ed8e53e5707ad.html
#------------------------------------------------
# 安装时版本：23.3.1
#------------------------------------------------
# Debug：
# rm -rf /opt/conda* && rm -rf /mountdisk/conf/conda* && rm -rf /mountdisk/logs/conda* && rm -rf /mountdisk/data/conda* && rm -rf /home/conda && rm -rf ~/.conda && rm -rf ~/.cache/conda && rm -rf /var/spool/mail/conda
# chmod -v u+w /etc/sudoers && cat /etc/sudoers | grep -En "^conda " | cut -d':' -f1 | xargs -I {} sh -c "sed -i '{}d' /etc/sudoers" && chmod -v u-w /etc/sudoers
# ps -ef | grep conda | awk 'NR>1{print $2}' | xargs kill -9
# cat /etc/shadow | grep -En "^conda:" | cut -d':' -f1 | xargs -I {} sh -c "sed -i '{}d' /etc/shadow"
# cat /etc/passwd | grep -En "^conda:" | cut -d':' -f1 | xargs -I {} sh -c "sed -i '{}d' /etc/passwd"
# vipw 手动删除用户
#------------------------------------------------
# 相关目录：
#         /opt/conda/bin/conda
#         /opt/conda/bin/conda-env
#         /opt/conda/bin/activate
#         /opt/conda/bin/deactivate
#         /opt/conda/etc/profile.d/conda.sh
#         /opt/conda/etc/fish/conf.d/conda.fish
#         /opt/conda/shell/condabin/Conda.psm1
#         /opt/conda/shell/condabin/conda-hook.ps1
#         /opt/conda/lib/python3.9/site-packages/xontrib/conda.xsh
#         /opt/conda/etc/profile.d/conda.csh
#------------------------------------------------
# 相关命令：
#         conda create -n pyenv37 python=3.7	        创建一个 Python 版本为 3.7 的虚拟环境
#         conda activate pyenv37	                    激活 pyenv37 虚拟环境
#         conda env list	                            列出当前 conda 管理的所有虚拟环境
#         conda list	                                列出当前环境的所有包
#         conda search --full-name <package_full_name>	搜索包
#         conda install requests	                    安装 requests 包
#         conda install -n root conda=3.6	            将 conda 的版本回退到 3.6
#         conda remove requests	                        卸载 requests 包
#         conda remove -n pyenv37 --all	                删除 pyenv37 环境以及环境中的所有包
#         conda update requests	                        更新 requests 包
#         conda env export > environment.yaml	        出当前环境的包信息
#         conda env create -f environment.yaml	        用配置文件创建新的虚拟环境
#         conda deactivate                              退出虚拟环境
#------------------------------------------------
local TMP_MCD_SETUP_CPU_STRUCT=$(uname -m)
local TMP_MCD_SETUP_DOWN_SH_FILE_NAME="Miniconda3-latest-Linux-${TMP_MCD_SETUP_CPU_STRUCT}.sh"
local TMP_MCD_SETUP_BC_PS_PORT=13000

##########################################################################################################

# 1-配置环境
function set_env_miniconda()
{
    echo_style_wrap_text "Starting 'configuare' <miniconda> 'install envs', hold on please"

    cd ${__DIR}

    # playwright插件需要
    soft_${SYS_SETUP_COMMAND}_check_setup 'atk at-spi2-atk cups-libs libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm gtk3'

	return $?
}

##########################################################################################################

# 2-安装软件(本安装利用头部有多余的注释字符串来控制长度，避免ER)提取执行文件原始变量
function setup_miniconda()
{
    echo_style_wrap_text "Starting 'install' <miniconda>, hold on please"

    # 检测还原安装（如果安装目录存在文件会报错：ERROR: File or directory already exists: '/opt/conda3'）

    ## 脚本安装(文件被下载在shell目录)
    function _setup_miniconda_down_install()
    {
        while_wget "https://repo.anaconda.com/miniconda/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}" "change_down_miniconda && bash ${SH_DIR}/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} && source ~/.bashrc"
    }
    soft_path_restore_confirm_custom "${TMP_MCD_SETUP_DIR}" "_setup_miniconda_down_install"
    soft_path_restore_confirm_create "${CONDA_APP_SETUP_DIR}"
    
	# 轻量级安装的情况下不进行安装包还原操作
	cd ${TMP_MCD_SETUP_DIR}
	
    # 安装初始

	return $?
}

# 2-x1 修改下载文件
function change_down_miniconda()
{
    # 二进制分界线（文件由脚本及二进制混合而成）
    local TMP_MCD_SETUP_SH_FILE_LINES=$(head -n 8 ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} | grep -aoE "^# LINES:.*" | cut -d' ' -f3)
    ## 不打行号的情况下，代码找
    if [ -z "${TMP_MCD_SETUP_SH_FILE_LINES}" ]; then
        ## 使用strings -会行号会不一致
        TMP_MCD_SETUP_SH_FILE_LINES=$(cat ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} | grep -naE "^@@END_HEADER@@$" | cut -d':' -f1)
    fi

    # 临时修改SHELL部分{注意，修改文件必先记录脚本可修改的块，否则二进制文件会变得无法执行:行412: /opt/conda/conda.exe: 无法执行二进制文件}
    ## 临时修改文件，提取脚本可修改块（避免文件内容操作加大响应延迟）
    local TMP_MCD_SETUP_SH_FILE_SH_NAME="shell_${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}"
    local TMP_MCD_SETUP_SH_FILE_PCKS_NAME="package_${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}"
    head -n $((TMP_MCD_SETUP_SH_FILE_LINES-1)) ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} > ${TMP_MCD_SETUP_SH_FILE_SH_NAME}
    ### sed -i "1,$((TMP_MCD_SETUP_SH_FILE_LINES-1))d" $((TMP_MCD_SETUP_SH_FILE_LINES-1)) && mv ${TMP_MCD_SETUP_SH_FILE_PCKS_NAME}
    tail -n +${TMP_MCD_SETUP_SH_FILE_LINES} ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} > ${TMP_MCD_SETUP_SH_FILE_PCKS_NAME}
    ## 统计到文件修改之前的实际字符起始位置
    local TMP_MCD_SETUP_SH_FILE_SPLIT_CHR_COUNT=$(cat ${TMP_MCD_SETUP_SH_FILE_SH_NAME} | wc -m)
    local TMP_MCD_SETUP_SH_FILE_MD5=$(cat ${TMP_MCD_SETUP_SH_FILE_SH_NAME} | grep -aoE "^# MD5:.*" | cut -d' ' -f5)
    
    ## 修改许可阅读确认
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@read -r dummy@#read -r dummy@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}

    ## 修改阅读太多内容(多种规格，不同版本这里有些差异)
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@\"\$pager\" <<EOF@pager=<<EOF@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@\"\$pager\" <<'EOF'@pager=<<EOF@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}

    ## 修改是否同意的选择默认为yes
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@read -r ans@ans='yes'@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}
    ## 修改安装目录确认
    ## 动态修改安装的DIR，miniconda自身也会升级，所以目录带了版本号
    ## sed -i "s@PREFIX=\$HOME@PREFIX=/opt@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}
    ## TMP_MCD_SETUP_DIR=$(cat ${TMP_MCD_SETUP_SH_FILE_SH_NAME} | grep -aoE "^PREFIX=/opt.*" | cut -d'=' -f2)
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@read -r user_prefix@user_prefix='${TMP_MCD_SETUP_DIR}'@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}

    ## 统计到文件修改以后的实际字符起始位置
    local TMP_MCD_SETUP_SH_FILE_FINAL_CHR_COUNT=$(cat ${TMP_MCD_SETUP_SH_FILE_SH_NAME} | wc -m)
    local TMP_MCD_SETUP_SH_FILE_DIFF_CHR_COUNT=$((TMP_MCD_SETUP_SH_FILE_FINAL_CHR_COUNT-TMP_MCD_SETUP_SH_FILE_SPLIT_CHR_COUNT))
    
    ## 删除注释部分MD5标记长度的字符串
    local TMP_MCD_SETUP_SH_FILE_REPLACE_MD5="${TMP_MCD_SETUP_SH_FILE_MD5}"
    if [ ${TMP_MCD_SETUP_SH_FILE_DIFF_CHR_COUNT} -ne 0 ]; then
        if [ ${TMP_MCD_SETUP_SH_FILE_DIFF_CHR_COUNT} -lt 0 ]; then
            # 填充/补全不够位空格
            TMP_MCD_SETUP_SH_FILE_REPLACE_MD5="${TMP_MCD_SETUP_SH_FILE_MD5}$(eval printf %.s'-' {1..${TMP_MCD_SETUP_SH_FILE_DIFF_CHR_COUNT#-}})"
        else
            TMP_MCD_SETUP_SH_FILE_REPLACE_MD5=${TMP_MCD_SETUP_SH_FILE_MD5:0:$((32-TMP_MCD_SETUP_SH_FILE_DIFF_CHR_COUNT))}
        fi
        
        sed -i "s@# MD5:   ${TMP_MCD_SETUP_SH_FILE_MD5}@# MD5:   ${TMP_MCD_SETUP_SH_FILE_REPLACE_MD5}@g" ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}
    fi

    # 修改完成合并安装脚本文件
    cat ${TMP_MCD_SETUP_SH_FILE_SH_NAME} > ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}
    cat ${TMP_MCD_SETUP_SH_FILE_PCKS_NAME} >> ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}

    rm -rfv ${TMP_MCD_SETUP_SH_FILE_SH_NAME}
    rm -rfv ${TMP_MCD_SETUP_SH_FILE_PCKS_NAME}
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'formal dirs' <miniconda>, hold on please"

	# 开始标准化	    
    # 预先初始化一次，启动后才有文件生成 & 创建conda用户，以用于执行安装操作
    create_user_if_not_exists "root" "conda" true
	
    # 还原 & 创建 & 迁移
    ## 日志
    soft_path_restore_confirm_create "${CONDA_APP_LOGS_DIR}"
	## 数据
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_ENVS_DIR}" "${TMP_MCD_SETUP_DATA_ENVS_DIR}"
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_ROOT_ENVS_DIR}" "${TMP_MCD_SETUP_DATA_ROOT_ENVS_DIR}"
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_HOME_ENVS_DIR}" "${TMP_MCD_SETUP_DATA_HOME_ENVS_DIR}"
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_PKGS_DIR}" "${TMP_MCD_SETUP_DATA_PKGS_DIR}"
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_ROOT_PKGS_DIR}" "${TMP_MCD_SETUP_DATA_ROOT_PKGS_DIR}"
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_HOME_PKGS_DIR}" "${TMP_MCD_SETUP_DATA_HOME_PKGS_DIR}"
    soft_path_restore_confirm_create "${CONDA_APP_DATA_DIR}"
    # soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_DATA_ENVS_DIR}" "/home/conda/.conda/envs"
	## CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_MCD_SETUP_LNK_CONF_DIR}" "${TMP_MCD_SETUP_CONF_DIR}"
    soft_path_restore_confirm_create "${CONDA_APP_CONF_DIR}"
    
	# 创建链接规则

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'configuration' <miniconda>, hold on please"

    # 同步新增的bashrc内容
    local TMP_MCD_SETUP_HOME_CONDA=$(su - conda -c "pwd")
    function _conf_miniconda_append_rc()
    {
        local TMP_MCD_SETUP_BASHRC_LINE_START=$(cat ~/.bashrc | grep -naE "^# >>> conda initialize >>>$" | cut -d':' -f1)
        tail -n +${TMP_MCD_SETUP_BASHRC_LINE_START} ~/.bashrc >> ${TMP_MCD_SETUP_HOME_CONDA}/.bashrc
    }
    file_content_not_exists_action "^# >>> conda initialize >>>$" "${TMP_MCD_SETUP_HOME_CONDA}/.bashrc" "_conf_miniconda_append_rc"

    # 授权
	chown -R conda:root ${TMP_MCD_SETUP_DIR}
	chown -R conda:root "${TMP_MCD_SETUP_DATA_HOME_ENVS_DIR}"
	chown -R conda:root "${TMP_MCD_SETUP_DATA_ROOT_ENVS_DIR}"
	chown -R conda:root "${TMP_MCD_SETUP_DATA_HOME_PKGS_DIR}"
	chown -R conda:root "${TMP_MCD_SETUP_DATA_ROOT_PKGS_DIR}"
    chown -R conda:root ${TMP_MCD_SETUP_LNK_DATA_DIR}
	chown -R conda:root ${TMP_MCD_SETUP_LNK_CONF_DIR}

    # 同步环境变量
    ## ~/.bashrc 中存在，故不启用，仅记录
	## 环境变量或软连接
	# echo_etc_profile "CONDA_HOME=${TMP_MCD_SETUP_DIR}"
    # echo_etc_profile 'PATH=$CONDA_HOME/bin:$PATH'
	# echo_etc_profile 'export CONDA_HOME'

    # 重新加载profile文件
	# source /etc/profile

    # 开始配置
    ## 生成 ~/.condarc配置文件
    ### 配置主环境登录不进入虚拟环境
    condabin/conda config --set auto_activate_base false
    su_bash_conda_channel_exec "conda config --set show_channel_urls yes"
    ## 是否自动确认
    # su_bash_conda_channel_exec "conda config --set always_yes yes"

    ### 设置SSL验证为false，否则可能出现（但是加了pip update时又会出现 SSL验证问题，囧rz）：
    # Collecting package metadata (current_repodata.json): failed
    # CondaSSLError: Encountered an SSL error. Most likely a certificate verification issue.
    # Exception: HTTPSConnectionPool(host='conda.anaconda.org', port=443): Max retries exceeded with url: /microsoft/linux-64/current_repodata.json (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: certificate is not yet valid (_ssl.c:997)')))
    # su_bash_conda_channel_exec "conda config --set ssl_verify false"

    local TMP_CMD_SETUP_CNLS=$(su_bash_conda_channel_exec "conda config --show-sources | grep '^  -' | cut -d' ' -f4")
    # item_not_exists_action "^https:\/\/mirrors.bfsu.edu.cn\/anaconda\/pkgs\/free\/$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/free/'"
    # item_not_exists_action "^https:\/\/mirrors.bfsu.edu.cn\/anaconda\/pkgs\/main\/$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/main/'"
    # item_not_exists_action "^https:\/\/mirrors.bfsu.edu.cn\/anaconda\/pkgs\/cloud\/conda-forge\/$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/cloud/conda-forge/'"
    # item_not_exists_action "^https:\/\/mirrors.bfsu.edu.cn\/anaconda\/pkgs\/cloud\/bioconda\/$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/cloud/bioconda/'"
    item_not_exists_action "^microsoft$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels microsoft'"
    item_not_exists_action "^conda-forge$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels conda-forge'"
    item_not_exists_action "^bioconda$" "${TMP_CMD_SETUP_CNLS}" "su_bash_conda_channel_exec 'conda config --add channels bioconda'"

	return $?
}

##########################################################################################################

# 5-测试软件
function test_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test' <miniconda> snapshot, hold on please"

	# 实验部分

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_miniconda()
{    
	cd ${TMP_MCD_SETUP_DIR}
    
	# 验证安装
    echo_style_wrap_text "Starting 'boot' <miniconda>, hold on please"

    ## 当前启动命令 && 等待启动
    echo_style_text "[View] the 'channels' from env([${PY_ENV}])↓:"
    su_bash_conda_channel_exec "conda config --get show_channel_urls"
    su_bash_conda_channel_exec "conda config --get channels"

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'sources' from env([${PY_ENV}])↓:"
    su_bash_conda_channel_exec "conda config --show-sources"

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'list' from env([${PY_ENV}])↓:"
	su_bash_conda_channel_exec "conda list"

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'env list'↓:"
	condabin/conda env list

    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'update'↓:"
    condabin/conda update -y conda
    
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'version'↓:"
    condabin/conda --version

    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'info'↓:"
    condabin/conda info

    # 结束
    exec_sleep 10 "Boot <miniconda> over, please checking the setup log, this will stay [%s] secs to exit"

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_ext_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}

    echo_style_wrap_text "Starting 'download' <miniconda> exts, hold on please"

    # 环境预装
    # condabin/conda run -n pyenv36 python --version | grep 'EnvironmentLocationNotFound'

    su_bash_conda_create_env "pyenv36" "3.6"
    # conda activate pyenv36
        
    su_bash_conda_create_env "pyenv37" "3.7"
    # conda activate pyenv37
        
    su_bash_conda_create_env "pyenv38" "3.8"
    # conda activate pyenv38
        
    su_bash_conda_create_env "pyenv39" "3.9"
    # conda activate pyenv39

	return $?
}

# 安装驱动/插件
function setup_ext_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'install' <miniconda> exts in env([${PY_ENV}]), wait for a moment"

    # 安装必要依赖插件
    soft_setup_conda_channel_pip "runlike" "whereis runlike"
    
    # 开始安装依赖扩展
    local TMP_MCD_SETUP_REQUIRED_DIR="$(cd "$(dirname ${__DIR}/${BASH_SOURCE[0]})" && pwd)"
    local TMP_MCD_SETUP_REQUIRED_SHS="$(cd ${TMP_MCD_SETUP_REQUIRED_DIR} && ls conda/*.sh)"
    items_split_action "TMP_MCD_SETUP_REQUIRED_SHS" "cd ${TMP_MCD_SETUP_REQUIRED_DIR} && source %s"
    
    # 新增兼容它监视正在运行的容器，如果有一个具有相同标记的新版本可用，它将拉取新映像并重新启动容器。
    # https://github.com/containrrr/watchtower 

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_miniconda()
{    
	set_env_miniconda 

	setup_miniconda 
	
	formal_miniconda 

	conf_miniconda 
	
	test_miniconda 

    down_ext_miniconda 
    setup_ext_miniconda 

	boot_miniconda 

	# reconf_miniconda 

    # 结束
    exec_sleep 30 "Install <conda> over, please checking the setup log, this will stay [%s] secs to exit"

	return $?
}

##########################################################################################################

function check_setup_miniconda()
{
    echo_style_wrap_text "Checking <miniconda> 'install', hold on please"

	# 变量覆盖特性，其它方法均可读取
	local TMP_MCD_SETUP_DIR=${SETUP_DIR}/conda
    
	# 统一编排到的路径
	local TMP_MCD_SETUP_LNK_DATA_DIR=${DATA_DIR}/conda
	local TMP_MCD_SETUP_LNK_DATA_ENVS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/envs/basic
	local TMP_MCD_SETUP_LNK_DATA_ROOT_ENVS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/envs/root
	local TMP_MCD_SETUP_LNK_DATA_HOME_ENVS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/envs/home
	local TMP_MCD_SETUP_LNK_DATA_PKGS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/pkgs/basic
	local TMP_MCD_SETUP_LNK_DATA_ROOT_PKGS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/pkgs/root
	local TMP_MCD_SETUP_LNK_DATA_HOME_PKGS_DIR=${TMP_MCD_SETUP_LNK_DATA_DIR}/pkgs/home
	local TMP_MCD_SETUP_LNK_CONF_DIR=${CONF_DIR}/conda
    
	# 安装后的真实路径（此处依据实际路径名称修改）
	local TMP_MCD_SETUP_DATA_ENVS_DIR=${TMP_MCD_SETUP_DIR}/envs
	local TMP_MCD_SETUP_DATA_HOME_ENVS_DIR="/home/conda/envs"
	local TMP_MCD_SETUP_DATA_ROOT_ENVS_DIR="/root/.conda/envs"
	local TMP_MCD_SETUP_DATA_PKGS_DIR=${TMP_MCD_SETUP_DIR}/pkgs
	local TMP_MCD_SETUP_DATA_HOME_PKGS_DIR="/home/conda/pkgs"
	local TMP_MCD_SETUP_DATA_ROOT_PKGS_DIR="/root/.conda/pkgs"

    ## 初始化时，目录便已存在路径为etc
	# local TMP_MCD_SETUP_CONF_DIR=${TMP_MCD_SETUP_DIR}/${DEPLOY_CONF_MARK}
    local TMP_MCD_SETUP_CONF_DIR=${TMP_MCD_SETUP_DIR}/etc

    # 临时
	local TMP_MCD_CURRENT_DIR=$(pwd)

    # *** miniconda本身具备了自动更新的操作，故不做重装还原操作，此处已安装的情况下，直接使用原有命令是最好的选择
    # function down_miniconda()
    # {
    #     while_wget "https://repo.anaconda.com/miniconda/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}" "change_down_miniconda && exec_step_miniconda"
    # }
	# command_check_action "conda" "conda update -y conda"
    # if [ $? -eq 0 ]; then
    #     down_miniconda
    # fi
    soft_cmd_check_upgrade_action "conda" "exec_step_miniconda" "su_bash_env_channel_exec 'conda update -y conda'"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "MiniConda" "check_setup_miniconda"