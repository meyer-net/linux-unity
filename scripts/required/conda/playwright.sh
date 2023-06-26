#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      Copyright https://devops.oshit.com/
#      Author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  
#------------------------------------------------
# 安装时版本：1.30.0
#------------------------------------------------
# Debug：
#------------------------------------------------
# 安装标题：PlayWright
# 软件名称：playwright
# 软件端口：9001
# 软件大写分组与简称：PLR
# 软件安装名称：playwright
# 软件授权用户名称&组：conda/conda
#------------------------------------------------

##########################################################################################################

# 1-配置环境
function set_env_playwright()
{
    echo_style_wrap_text "Starting 'configuare install envs' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

    cd ${__DIR}

    # soft_${SYS_SETUP_COMMAND}_check_setup ""

	return $?
}

##########################################################################################################

# 2-安装软件
function setup_playwright()
{
    echo_style_wrap_text "Starting 'install' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

    # 创建安装目录(纯属为了规范)
    soft_path_restore_confirm_create "${TMP_PLR_SETUP_DIR}"
	
	# 开始安装
	cd ${TMP_PLR_SETUP_DIR}

    # 执行环境内二次安装
    su_bash_conda_echo_profile 'export DISPLAY=:0' "" "${TMP_PLR_SETUP_ENV}"
    su_bash_env_conda_channel_exec "playwright install" "${TMP_PLR_SETUP_ENV}"

	return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_playwright()
{
	cd ${TMP_PLR_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal dirs' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	# 开始标准化	    
    # # 预先初始化一次，启动后才有文件生成
    # systemctl start playwright.service
	
    # 还原 & 创建 & 迁移
	## 日志
	soft_path_restore_confirm_create "${TMP_PLR_SETUP_LNK_LOGS_DIR}"
	## 数据
	soft_path_restore_confirm_create "${TMP_PLR_SETUP_LNK_DATA_DIR}"

	# # 创建链接规则
	## 工作
	path_not_exists_link "${TMP_PLR_SETUP_WORK_DIR}" "" "${TMP_PLR_SETUP_LNK_WORK_DIR}"
	## 日志
	path_not_exists_link "${TMP_PLR_SETUP_LOGS_DIR}" "" "${TMP_PLR_SETUP_LNK_LOGS_DIR}"
	## 数据
	path_not_exists_link "${TMP_PLR_SETUP_DATA_DIR}" "" "${TMP_PLR_SETUP_LNK_DATA_DIR}"

	# 预实验部分
    ## 目录调整完重启进程(目录调整是否有效的验证点)

	return $?
}

##########################################################################################################

# 4-设置软件
function conf_playwright()
{
	cd ${TMP_PLR_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'configuration' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	# 开始配置
	## 环境变量或软连接 /etc/profile写进函数
	su_bash_conda_echo_profile "PLAYWRIGHT_HOME=${TMP_PLR_SETUP_DIR}" "" "${TMP_PLR_SETUP_ENV}"
	su_bash_conda_echo_profile 'PATH=$PLAYWRIGHT_HOME/bin:$PATH' "" "${TMP_PLR_SETUP_ENV}"
	su_bash_conda_echo_profile 'export PATH PLAYWRIGHT_HOME' "" "${TMP_PLR_SETUP_ENV}"

    # ## 修改服务运行用户
    # change_service_user conda conda

	## 授权权限，否则无法写入
	chown -R conda:root ${TMP_PLR_SETUP_DIR}
	chown -R conda:root ${TMP_PLR_SETUP_LNK_WORK_DIR}
	chown -R conda:root ${TMP_PLR_SETUP_LNK_LOGS_DIR}
	chown -R conda:root ${TMP_PLR_SETUP_LNK_DATA_DIR}
    
	## 修改配置文件
	
	return $?
}

##########################################################################################################

# 5-测试软件
function test_playwright()
{
	cd ${TMP_PLR_SETUP_DIR}

    echo_style_wrap_text "Starting 'test' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	# 实验部分
    ## 写入playwright依赖，用于脚本查询dockerhub中的版本信息。su - $(whoami) -c "source activate ${TMP_PLR_SETUP_ENV} && python ${TMP_PLR_SETUP_DATA_DIR}/py/pw_sync_fetch_docker_hub_vers.py | grep -v '\-rc' | cut -d '-' -f1 | uniq"
    ## 参考：https://zhuanlan.zhihu.com/p/347213089
    path_not_exists_create "${TMP_PLR_SETUP_DATA_DIR}/py"
    cat >${TMP_PLR_SETUP_DATA_DIR}/py/pw_sync_fetch_docker_hub_vers.py<<EOF
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

    cat >${TMP_PLR_SETUP_DATA_DIR}/py/pw_async_fetch_docker_hub_vers.py<<EOF
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

    cat >${TMP_PLR_SETUP_DATA_DIR}/py/pw_async_fetch_docker_hub_ver_digests.py<<EOF
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

    cat >${TMP_PLR_SETUP_DATA_DIR}/py/pw_async_fetch_url_selector_attr.py<<EOF
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

    echo_style_text "Testing ext <playwright>@[${TMP_PLR_SETUP_ENV}] for 'labring/sealos' to get ver list, wait for a moment"
    su_bash_env_conda_channel_exec "cd ${TMP_PLR_SETUP_DATA_DIR} && python py/pw_sync_fetch_docker_hub_vers.py 'labring/sealos'"

    echo ${TMP_SPLITER2}
    echo_style_text "Testing ext <playwright-async>@[${TMP_PLR_SETUP_ENV}] for 'labring/sealos' to get ver list, wait for a moment"
    su_bash_env_conda_channel_exec "cd ${TMP_PLR_SETUP_DATA_DIR} && python py/pw_async_fetch_docker_hub_vers.py 'labring/sealos'"

	return $?
}

##########################################################################################################

# 6-启动软件
function boot_playwright()
{
	cd ${TMP_PLR_SETUP_DIR}
	
	# 验证安装/启动
    # 当前启动命令 && 等待启动
    echo_style_wrap_text "Starting 'boot check' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"
	
    # 打印版本
    echo_style_text "[View] the 'version'↓:"
    su_bash_env_conda_channel_exec "playwright -V" "${TMP_PLR_SETUP_ENV}"
	
    echo "${TMP_SPLITER2}"	
    echo_style_text "[View] the 'help'↓:"
    su_bash_env_conda_channel_exec "playwright -h" "${TMP_PLR_SETUP_ENV}"

    # 结束
    exec_sleep 10 "Boot <playwright> over, please checking the setup log, this will stay %s secs to exit"

	return $?
}

##########################################################################################################

# 下载驱动/插件
function down_ext_playwright()
{
    cd ${TMP_PLR_SETUP_DIR}

    echo_style_wrap_text "Starting 'download exts' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	return $?
}

# 安装驱动/插件
function setup_ext_playwright()
{
    cd ${TMP_PLR_SETUP_DIR}

    echo_style_wrap_text "Starting 'install exts' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# 重新配置（有些软件安装完后需要重新配置）
function reconf_playwright()
{
    cd ${TMP_PLR_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' in env(<${TMP_PLR_SETUP_ENV}>), hold on please"

	return $?
}

##########################################################################################################

# x2-执行步骤
function exec_step_playwright()
{
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_PLR_SETUP_NAME="${1}"
    local TMP_PLR_SETUP_MARK_NAME="${1/\//_}"
    local TMP_PLR_SETUP_VER="${2}"
    local TMP_PLR_SETUP_ENV="${3}"
    local TMP_PLR_SETUP_LNK_WORK_DIR="${4}"
		
	## 环境变量 
	local TMP_PLR_SETUP_MCD_SETUP_DIR=$(su_bash_env_conda_channel_exec "conda info --base" "${TMP_PLR_SETUP_ENV}")
	local TMP_PLR_SETUP_MCD_ENVS_DIR=${TMP_PLR_SETUP_MCD_SETUP_DIR}/envs/${TMP_PLR_SETUP_ENV}
    
	## 统一编排到的路径
    local TMP_PLR_CURRENT_DIR=$(pwd)
	local TMP_PLR_SETUP_DIR=${CONDA_APP_SETUP_DIR}/${TMP_PLR_SETUP_MARK_NAME}
	local TMP_PLR_SETUP_LNK_LOGS_DIR=${CONDA_APP_LOGS_DIR}/${TMP_PLR_SETUP_MARK_NAME}
	local TMP_PLR_SETUP_LNK_DATA_DIR=${CONDA_APP_DATA_DIR}/${TMP_PLR_SETUP_MARK_NAME}

	## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_PLR_SETUP_BIN_DIR=${TMP_PLR_SETUP_DIR}/bin
	local TMP_PLR_SETUP_WORK_DIR=${TMP_PLR_SETUP_DIR}/${DEPLOY_WORK_MARK}
	local TMP_PLR_SETUP_LOGS_DIR=${TMP_PLR_SETUP_DIR}/${DEPLOY_LOGS_MARK}
	local TMP_PLR_SETUP_DATA_DIR=${TMP_PLR_SETUP_DIR}/scripts

	set_env_playwright 

	setup_playwright 
	
	formal_playwright 

	conf_playwright 
	
	test_playwright 

    # down_ext_playwright 
    # setup_ext_playwright 

	boot_playwright 

	# reconf_playwright 

    # 结束
    exec_sleep 30 "Install <playwright> over, please checking the setup log, this will stay %s secs to exit"

	return $?
}

##########################################################################################################

# x1-检测软件安装
function check_setup_playwright()
{
	# local TMP_PLR_SETUP_LNK_DATA_DIR=${DATA_DIR}/playwright
    # path_not_exists_action "${TMP_PLR_SETUP_LNK_DATA_DIR}" "exec_step_playwright" "PlayWright was installed"

    # 安装playwright插件，版本只能1.30.0，不然GLIBC不匹配
	soft_setup_conda_pip "playwright" "exec_step_playwright" "1.30.0"

	return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "PlayWright" "check_setup_playwright"