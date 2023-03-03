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
local TMP_MCD_SETUP_BC_PS_PORT=13000

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
    # 检测还原安装（如果安装目录存在文件会报错：ERROR: File or directory already exists: '/opt/miniconda3'）

    ## 脚本安装(文件被下载在shell目录)
    while_wget "https://repo.anaconda.com/miniconda/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME}" "change_down_miniconda && bash ${SH_DIR}/${TMP_MCD_SETUP_DOWN_SH_FILE_NAME} && source ~/.bashrc"
    
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

    ## 修改阅读太多内容
    sed -i -e "1,${TMP_MCD_SETUP_SH_FILE_LINES} s@\"\$pager\" <<EOF@pager=<<EOF@g" ${TMP_MCD_SETUP_SH_FILE_SH_NAME}

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

	# 开始标准化	    
    # # 预先初始化一次，启动后才有文件生成
    # systemctl start miniconda.service
	
    # 还原 & 创建 & 迁移
	## 数据
    soft_path_restore_confirm_swap "${TMP_MCD_SETUP_LNK_ENVS_DIR}" "${TMP_MCD_SETUP_ENVS_DIR}"
	## ETC - ①-1Y：存在配置文件：原路径文件放给真实路径
	soft_path_restore_confirm_move "${TMP_MCD_SETUP_LNK_ETC_DIR}" "${TMP_MCD_SETUP_ETC_DIR}"
    ## 自定义-脚本
    soft_path_restore_confirm_create "${TMP_MCD_SETUP_LNK_SCRIPTS_DIR}"

	# 创建链接规则
	## 自定义-脚本
	path_not_exists_link "${TMP_MCD_SETUP_SCRIPTS_DIR}" "" "${TMP_MCD_SETUP_LNK_SCRIPTS_DIR}" 

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
	echo
    echo_style_text "Configuration 'conda packages', wait for a moment"
    echo "${TMP_SPLITER}"

    # ~/.bashrc 中存在，故不启用
	# # 环境变量或软连接
	# echo_etc_profile "MINICONDA_HOME=${TMP_MCD_SETUP_DIR}"
	# echo_etc_profile 'PATH=$MINICONDA_HOME/condabin:$PATH'
	# echo_etc_profile 'export PATH MINICONDA_HOME'

    # # 重新加载profile文件
	# source /etc/profile
    
    # 生成 ~/.condarc配置文件
    condabin/conda config --set auto_activate_base false
    condabin/conda config --set show_channel_urls yes

	return $?
}

##########################################################################################################

# 5-测试软件
function test_miniconda()
{
	# 实验部分

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_miniconda()
{    
	cd ${TMP_MCD_SETUP_DIR}
    
	# 验证安装
    ## 当前启动命令 && 等待启动
    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'channels'↓:"
    condabin/conda config --get show_channel_urls
    condabin/conda config --get channels

    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'sources'↓:"
    condabin/conda config --show-sources

    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'list'↓:"
	condabin/conda list

    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'env list'↓:"
	condabin/conda env list

    echo "${TMP_SPLITER2}"
    echo_style_text "View the 'update'↓:"
    condabin/conda update -y conda
    
    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'version'↓:"
    condabin/conda --version

    echo "${TMP_SPLITER2}"	
    echo_style_text "View the 'info'↓:"
    condabin/conda info -e

    # 结束
    exec_sleep 10 "Search <miniconda> over, please checking the setup log, this will stay 10 secs to exit"

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_ext_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}

    # 环境预装
    local TMP_CMD_SETUP_CNLS=$(condabin/conda config --show-sources | grep "^  -" | cut -d' ' -f4)
    # condabin/conda run -n pyenv36 python --version | grep 'EnvironmentLocationNotFound'
    local TMP_MCD_SETUP_ENVS=$(condabin/conda info -e | cut -d' ' -f1 | grep -v "#" | grep -v "base" | grep -v "^$")

    item_not_exists_action "^conda-forge$" "${TMP_CMD_SETUP_CNLS}" "condabin/conda config --add channels conda-forge"
    item_not_exists_action "^conda-forge$" "${TMP_CMD_SETUP_CNLS}" "condabin/conda config --add channels microsoft"

    item_not_exists_action "^pyenv36$" "${TMP_MCD_SETUP_ENVS}" "condabin/conda create -n pyenv36 -y python=3.6"
    # conda activate pyenv36
        
    item_not_exists_action "^pyenv37$" "${TMP_MCD_SETUP_ENVS}" "condabin/conda create -n pyenv37 -y python=3.7"
    # conda activate pyenv37
        
    item_not_exists_action "^pyenv38$" "${TMP_MCD_SETUP_ENVS}" "condabin/conda create -n pyenv38 -y python=3.8"
    # conda activate pyenv38
        
    item_not_exists_action "^pyenv39$" "${TMP_MCD_SETUP_ENVS}" "condabin/conda create -n pyenv39 -y python=3.9"
    # conda activate pyenv39

	return $?
}

# 安装驱动/插件
function setup_ext_miniconda()
{
	cd ${TMP_MCD_SETUP_DIR}
    
	echo
    echo_style_text "Starting install 'plugin-ext' 'playwright'@[${PY_ENV}], wait for a moment"

    # 安装playwright插件
    soft_${SYS_SETUP_COMMAND}_check_setup 'atk at-spi2-atk cups-libs libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm gtk3'
    echo ${TMP_SPLITER2}
    soft_setup_conda_pip "playwright" "export DISPLAY=:0 && playwright install"
    echo_style_text "Plugin 'playwright'@[${PY_ENV}] installed"
    echo ${TMP_SPLITER2}
    soft_setup_conda_pip "runlike" "whereis runlike"
    echo ${TMP_SPLITER2}
    soft_setup_conda_pip "whaler" "whereis whaler"
 
    # 写入playwright依赖，用于脚本查询dockerhub中的版本信息。su - `whoami` -c "source activate ${PY_ENV} && python ${CONDA_PW_SCRIPTS_DIR}/pw_sync_fetch_docker_hub_vers.py | grep -v '\-rc' | cut -d '-' -f1 | uniq"
    ## 参考：https://zhuanlan.zhihu.com/p/347213089
    path_not_exists_create "${CONDA_PW_SCRIPTS_DIR}"
    cat >${CONDA_PW_SCRIPTS_DIR}/pw_sync_fetch_docker_hub_vers.py<<EOF
import argparse
from playwright.sync_api import Playwright, sync_playwright

# def on_response(response):
#     if '.png' in response.url:
#         print(1)

# def on_response(response):
#     print('--------start---------')
#     print(request.url)
#     print(request.post_data)
#     print('--------end---------')

def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    # page.on('request', on_request)
    # page.on('response', on_response)

    try:
        parser = argparse.ArgumentParser(description='提供指定docker仓库的tags版本列表查询')
        parser.add_argument('image', help='镜像地址，例 labring/sealos')
        args = parser.parse_args()
        
        page.goto("https://hub.docker.com/r/{}/tags".format(args.image), wait_until='networkidle')

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

    cat >${CONDA_PW_SCRIPTS_DIR}/pw_async_fetch_docker_hub_vers.py<<EOF
import argparse
import asyncio
from playwright.async_api import async_playwright

async def main():
    parser = argparse.ArgumentParser(description='提供指定docker仓库的tags版本列表查询')
    parser.add_argument('image', help='镜像地址，例 labring/sealos')
    args = parser.parse_args()

    #ws_endpoint = "wss://localhost:${TMP_MCD_SETUP_BC_PS_PORT}/?token={}".format("")
    
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch(headless=True)
        # browser = await playwright.chromium.connect(ws_endpoint=ws_endpoint)
        context = await browser.new_context() 

        try:
            page = await context.new_page()
            
            await page.goto("https://hub.docker.com/r/{}/tags".format(args.image), wait_until='networkidle')
            # await page.wait_for_load_state(stat="networkidle")

            # 获取跳转到镜像的元素
            ver_locators = page.get_by_test_id("navToImage")
            ver_arr = await ver_locators.all_inner_texts()
            for ver in ver_arr:
                print(ver)
        finally:
            await context.close()
            await browser.close()

asyncio.get_event_loop().run_until_complete(main())
EOF

    cat >${CONDA_PW_SCRIPTS_DIR}/pw_async_fetch_docker_hub_ver_digests.py<<EOF
import argparse
import asyncio
from playwright.async_api import async_playwright

async def main():
    parser = argparse.ArgumentParser(description='提供指定docker仓库的tags版本列表查询')
    parser.add_argument('image', help='镜像地址，例 labring/sealos')
    parser.add_argument('ver', help='镜像版本，例 latest')
    args = parser.parse_args()

    #ws_endpoint = "wss://localhost:${TMP_MCD_SETUP_BC_PS_PORT}/?token={}".format("")
    
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch(headless=True)
        # browser = await playwright.chromium.connect(ws_endpoint=ws_endpoint)
        context = await browser.new_context() 

        try:
            page = await context.new_page()
            
            await page.goto("https://hub.docker.com/r/{}/tags".format(args.image), wait_until='networkidle')
            # await page.wait_for_load_state(stat="networkidle")
            
            # 获取跳转到镜像的元素
            #list_items = page.get_by_test_id("repotagsTagListItem")
            #for list_item in await list_items.all():
            #    item_ver_node = list_item.get_by_test_id("navToImage")
            #    for item_ver_node_text in await item_ver_node.all_inner_texts():
            #        # 获取对应的版本号，找到匹配的
            #        if (item_ver_node_text == args.ver):
            #            print(await list_item.get_by_test_id("repotagsImageList-{}".format(args.ver)).locator("div:has(span)").locator(".MuiTypography-root").all_inner_texts())

            # 获取跳转到镜像的元素
            # 参考 http://playwright.dev/python/docs/api/class-locator
            ver_row = page.get_by_test_id("repotagsImageList-{}".format(args.ver))
            # 开始找寻节点下的tags
            ver_tags = await ver_row.locator(".MuiTypography-root").all_inner_texts()
            for ver_tag in ver_tags:
                print(ver_tag)
        finally:
            await context.close()
            await browser.close()

asyncio.get_event_loop().run_until_complete(main())
EOF

    cat >${CONDA_PW_SCRIPTS_DIR}/pw_async_fetch_url_selector_attr.py<<EOF
import argparse
import asyncio
from playwright.async_api import async_playwright

async def main():
    parser = argparse.ArgumentParser(description='提供指定URL的选择器内容查询')
    parser.add_argument('url', help='访问地址，例：https://nodejs.org/en/')
    parser.add_argument('selector', help='选择器，例：a[class=home-downloadbutton]:has-text("Recommended For Most Users")')
    parser.add_argument('attr', default="inner_text", help='属性，例：text_content/inner_text/inner_html')
    args = parser.parse_args()
    
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch(headless=True)
        context = await browser.new_context() 

        try:
            page = await context.new_page()
            
            await page.goto(args.url, wait_until='networkidle')
            await page.wait_for_selector(args.selector)
            
            # 获取跳转到镜像的元素
            handles = await page.query_selector_all(args.selector)
            for handle in handles:
                print(await getattr(handle, args.attr)())
        finally:
            await context.close()
            await browser.close()

asyncio.get_event_loop().run_until_complete(main())
EOF

    # 测试插件
	echo ${TMP_SPLITER2}
    echo_style_text "Testing ext 'playwright'@[${PY_ENV}] for <labring/sealos> to get ver list, wait for a moment"
    su_bash_channel_conda_exec "cd ${CONDA_PW_SCRIPTS_DIR} && python pw_sync_fetch_docker_hub_vers.py 'labring/sealos'"

    echo ${TMP_SPLITER2}
    echo_style_text "Testing ext 'playwright-async'@[${PY_ENV}] for <labring/sealos> to get ver list, wait for a moment"
    su_bash_channel_conda_exec "cd ${CONDA_PW_SCRIPTS_DIR} && python pw_async_fetch_docker_hub_vers.py 'labring/sealos'"

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

	return $?
}

##########################################################################################################

function check_setup_miniconda()
{
	# 变量覆盖特性，其它方法均可读取
	local TMP_MCD_SETUP_DIR=${SETUP_DIR}/conda
    
	# 统一编排到的路径
	local TMP_MCD_SETUP_LNK_ENVS_DIR=${DATA_DIR}/conda
    local TMP_MCD_SETUP_LNK_SCRIPTS_DIR=${DATA_DIR}/conda_scripts
	local TMP_MCD_SETUP_LNK_ETC_DIR=${ATT_DIR}/conda
    
	# 安装后的真实路径（此处依据实际路径名称修改）
	local TMP_MCD_SETUP_ENVS_DIR=${TMP_MCD_SETUP_DIR}/envs
	local TMP_MCD_SETUP_ETC_DIR=${TMP_MCD_SETUP_DIR}/etc
	local TMP_MCD_SETUP_SCRIPTS_DIR=${TMP_MCD_SETUP_DIR}/scripts

    # 临时
	local TMP_MCD_CURRENT_DIR=`pwd`

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

#安装主体
soft_setup_basic "MiniConda" "check_setup_miniconda"