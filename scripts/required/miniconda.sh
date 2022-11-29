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
# 相关目录：
#         /opt/miniconda/bin/conda
#         /opt/miniconda/bin/conda-env
#         /opt/miniconda/bin/activate
#         /opt/miniconda/bin/deactivate
#         /opt/miniconda/etc/profile.d/conda.sh
#         /opt/miniconda/etc/fish/conf.d/conda.fish
#         /opt/miniconda/shell/condabin/Conda.psm1
#         /opt/miniconda/shell/condabin/conda-hook.ps1
#         /opt/miniconda/lib/python3.9/site-packages/xontrib/conda.xsh
#         /opt/miniconda/etc/profile.d/conda.csh
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
#------------------------------------------------
local TMP_MCD_SETUP_CPU_STRUCT=`uname -m`
local TMP_MCD_SETUP_DOWN_SH_FILE_NAME="Miniconda3-latest-Linux-${TMP_MCD_SETUP_CPU_STRUCT}.sh"

##########################################################################################################

# 1-配置环境
function set_env_miniconda()
{
    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件(本安装利用头部有多余的注释字符串来控制长度，避免ER)提取执行文件原始变量
function setup_miniconda()
{
    # 二进制分界线（文件由脚本及二进制混合而成）
    local TMP_MCD_SETUP_SH_FILE_LINES=$(head -n 8 ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} | grep -aoE "^# LINES:.*" | cut -d' ' -f3)

    # 临时修改SHELL部分{注意，修改文件必先记录脚本可修改的块，否则二进制文件会变得无法执行:行412: /opt/miniconda/conda.exe: 无法执行二进制文件}
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

    # 检测还原安装（如果安装目录存在文件会报错：ERROR: File or directory already exists: '/opt/miniconda3'）

    ## 脚本安装
    bash ${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}

	# 轻量级安装的情况下不进行安装包还原操作
	cd ${TMP_MCD_SETUP_DIR}

	# 创建软链
	local TMP_MCD_SETUP_LNK_ENVS_DIR=${DATA_DIR}/miniconda
	local TMP_MCD_SETUP_ENVS_DIR=${TMP_MCD_SETUP_DIR}/envs
	
    # 还原 & 迁移
	soft_path_restore_confirm_move "${TMP_MCD_SETUP_ENVS_DIR}" "${TMP_MCD_SETUP_LNK_ENVS_DIR}"
	path_not_exists_link "${TMP_MCD_SETUP_ENVS_DIR}" "" "${TMP_MCD_SETUP_LNK_ENVS_DIR}"

	# 环境变量或软连接 ？？？/etc/profile写进函数
	echo "MINICONDA_HOME=${TMP_MCD_SETUP_DIR}" >> /etc/profile
	echo 'PATH=$MINICONDA_HOME/condabin:$PATH' >> /etc/profile
	echo 'export PATH MINICONDA_HOME' >> /etc/profile

    # 重新加载profile文件
	source /etc/profile

    # 安装初始

	return $?
}

##########################################################################################################

# 3-设置软件
function conf_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    # 没有特别的配置，无需配置

	return $?
}

##########################################################################################################

# 4-启动软件
function boot_miniconda()
{    
	cd ${TMP_MCD_SETUP_DIR}
    
	# 验证安装
    condabin/conda --version

    # 生成 ~/.condarc配置文件
    condabin/conda config --setshow_channel_urls yes
	
    # 当前启动命令 && 等待启动
	echo
    echo "Searching conda packages，Waiting for a moment"
    echo "--------------------------------------------"
	condabin/conda list
    echo "--------------------------------------------"

    condabin/conda info -e

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_plugin_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}

    # 环境预装
    condabin/conda config --add channels conda-forge
    condabin/conda config --add channels microsoft

    condabin/conda create -n pyenv36 -y python=3.6
    # source activate pyenv36

    condabin/conda create -n pyenv37 -y python=3.7
    # source activate pyenv37

    condabin/conda create -n pyenv38 -y python=3.8
    # source activate pyenv38
    
    condabin/conda create -n pyenv39 -y python=3.9
    # source activate pyenv39

	return $?
}

# 安装驱动/插件
function setup_plugin_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
    # 安装playwright插件
    su - `whoami` -c "soft_${SYS_SETUP_COMMAND}_check_setup 'atk at-spi2-atk cups-libs libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm gtk3'"
    su - `whoami` -c "cd `pwd` && source activate ${PY_ENV} && pip install playwright && export DISPLAY=:0 && playwright install"
    
    # 写入playwright依赖，用于脚本查询dockerhub中的版本信息。su - `whoami` -c "source activate ${PY_ENV} && python ${TMP_MCD_SETUP_PW_PY_DIR}/get_docker_hub_vers.py | grep -v '\-rc' | cut -d '-' -f1 | uniq"
    local TMP_MCD_SETUP_PW_PY_DIR="${TMP_MCD_SETUP_DIR}/scripts/py"
    path_not_exists_create "${TMP_MCD_SETUP_PW_PY_DIR}"
    cat >${TMP_MCD_SETUP_PW_PY_DIR}/get_docker_hub_vers.py<<EOF
from playwright.sync_api import Playwright, sync_playwright

def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    try:
        page.goto("https://hub.docker.com/r/labring/sealos/tags", wait_until='networkidle')

        # 获取跳转到镜像的元素
        ver_locators = page.get_by_test_id("navToImage")
        ver_arr = ver_locators.all_inner_texts()
        for ver in ver_arr:
            print(ver)
    finally:
        context.close()
        browser.close()


with sync_playwright() as playwright:
    run(playwright)
EOF

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_miniconda()
{
	# 变量覆盖特性，其它方法均可读取
	local TMP_MCD_SETUP_DIR=${1}
	local TMP_MCD_CURRENT_DIR=`pwd`
    
	set_env_miniconda 

	setup_miniconda 

	conf_miniconda 

    down_plugin_miniconda 
    setup_plugin_miniconda 

	boot_miniconda 

	# reconf_miniconda 

	return $?
}

##########################################################################################################

# x1-下载软件
function down_miniconda()
{
    # *** miniconda本身具备了自动更新的操作，故不做重装还原操作，此处已安装的情况下，直接使用原有命令是最好的选择
    setup_soft_wget "miniconda" "https://repo.anaconda.com/miniconda/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}" "exec_step_miniconda" "" "conda update -y conda"

	return $?
}

##########################################################################################################

#安装主体
setup_soft_basic "MiniConda" "down_miniconda"
