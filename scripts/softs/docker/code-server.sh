#!/bin/bash
#------------------------------------------------
#      Centos7 Project Env InstallScript
#      copyright https://devops.oshit.com/
#      author: meyer.cheng
#------------------------------------------------
# 相关参考：
#		  Arm参考：https://hub.docker.com/r/linuxserver/code-server
#------------------------------------------------
# 安装版本：4.14.1
#------------------------------------------------
# source scripts/softs/docker/code-server.sh
#------------------------------------------------
# Debug：
# dpa --no-trunc | awk '{if($2~"codercom"){print $1}}' | xargs docker stop
# dpa --no-trunc | awk '{if($2~"codercom"){print $1}}' | xargs docker rm
# di | awk '{if($1~"codercom"){print $3}}' | xargs docker rmi
# rm -rf /mountdisk/conf/conda && mv /opt/conda/etc /mountdisk/conf/conda && ln -sf /mountdisk/conf/conda /opt/conda/etc && chown -R root:root /mountdisk/conf/conda /opt/conda && rm -rf /mountdisk/data/conda/envs/basic && mv /opt/conda/envs /mountdisk/data/conda/envs/basic && ln -sf /mountdisk/data/conda/envs/basic /opt/conda/envs && rm -rf /mountdisk/data/conda/pkgs/basic && mv /opt/conda/pkgs /mountdisk/data/conda/pkgs/basic && ln -sf /mountdisk/data/conda/pkgs/basic /opt/conda/pkgs && chown -R root:root /mountdisk/data/conda
# rm -rf /opt/docker_apps/codercom_code-server* && rm -rf /mountdisk/conf/docker_apps/codercom_code-server* && rm -rf /mountdisk/logs/docker_apps/codercom_code-server* && rm -rf /mountdisk/data/docker_apps/codercom_code-server* && rm -rf /opt/docker/data/apps/codercom_code-server* && rm -rf /opt/docker/conf/codercom_code-server* && rm -rf /opt/docker/logs/codercom_code-server* && rm -rf /mountdisk/repo/migrate/clean/codercom_code-server* && rm -rf /mountdisk/svr_sync/coder
# rm -rf /mountdisk/repo/backup/opt/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/conf/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/logs/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/mountdisk/data/docker_apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/data/apps/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/conf/codercom_code-server* && rm -rf /mountdisk/repo/backup/opt/docker/logs/codercom_code-server*
# ls -lia /opt/conda/ && ls -lia /mountdisk/conf/conda && ls -lia /mountdisk/data/conda/envs/basic && ls -lia /mountdisk/data/conda/pkgs/basic
# dvl | awk 'NR>1{print $2}' | xargs docker volume rm
#------------------------------------------------
local TMP_DC_CS_DISPLAY_TITLE="Code-Server"
local TMP_DC_CS_SETUP_IMG_FROM="codercom"
local TMP_DC_CS_SETUP_IMG_PRJT="code-server"
local TMP_DC_CS_SETUP_IMG_REPO="${TMP_DC_CS_SETUP_IMG_FROM}/${TMP_DC_CS_SETUP_IMG_PRJT}"
local TMP_DC_CS_SETUP_IMG_USER="coder"
local TMP_DC_CS_SETUP_INN_PORT=8080
local TMP_DC_CS_SETUP_OPN_PORT=1024

##########################################################################################################

# 1-配置环境
function set_env_dc_codercom_code-server() {
    echo_style_wrap_text "Starting 'configuare' <${TMP_DC_CS_SETUP_IMG_NAME}> 'install' [envs], hold on please"

    # docker exec -u root -it 38f sh -c "apt-get -y install jq"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y update"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install iproute2"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install vim"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install wget"
    # echo "${TMP_SPLITER3}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install jq"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install lsof"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install zip"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install unzip"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install rsync"
    echo "${TMP_SPLITER3}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install tmux"

    cd ${__DIR}

    return $?
}

##########################################################################################################

# 2-安装软件
function setup_dc_codercom_code-server() {
    echo_style_wrap_text "Starting 'install' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    function _setup_dc_codercom_code-server_cp_source() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'workingdir copy'↓:"

        # 拷贝应用目录
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:/usr/lib/${TMP_DC_CS_SETUP_APP_MARK} ${1} >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}
        
        # 查看拷贝列表
        ls -lia ${1}
    }

    # 创建安装目录(纯属为了规范)
    ## 1：存在working dir
    soft_path_restore_confirm_pcreate "${TMP_DC_CS_SETUP_WORK_DIR}" "_setup_dc_codercom_code-server_cp_source"
    
    # 创建工作目录
    ## 1：手动创建关联workspace dir
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'workspace initialize'↓:"
    ## /mountdisk/svr_sync/coder
    path_not_exists_create "${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}"
    ## /opt/docker_apps/codercom_code-server/4.14.1/workspace -> /mountdisk/svr_sync/coder
    path_not_exists_link "${TMP_DC_CS_SETUP_WORKSPACE_DIR}" "" "${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}"

    cd ${TMP_DC_CS_SETUP_DIR}

    # 开始安装
    ################################################################################################
    # 应用网站项目目录
    local TMP_DC_CS_SETUP_PRJ_WWW_DIR=${TMP_DC_CS_SETUP_WORKSPACE_DIR}/projects/www
    # 应用网站自启动目录
    local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/boots
    # 应用网站自启动服务器目录
    local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_NGX_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/nginx
    local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_ORT_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/openresty
    local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_CDY_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/caddy
    local TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DOC_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}/docker
    # 应用网站初始化目录
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/init
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MSQ_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mysql
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MDB_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mariadb
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_PSQ_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/postgresql
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_MGDB_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/mongodb
    local TMP_DC_CS_SETUP_PRJ_WWW_INIT_CH_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}/clickhouse
    # 应用网站项目语种对应目录
    local TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_DIR}/lang
    local TMP_DC_CS_SETUP_PRJ_WWW_LUA_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}/lua
    local TMP_DC_CS_SETUP_PRJ_WWW_PHP_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}/php
    local TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}/python
    local TMP_DC_CS_SETUP_PRJ_WWW_JV_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}/java
    local TMP_DC_CS_SETUP_PRJ_WWW_HTML_DIR=${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}/html

    # 应用项目目录
    local TMP_DC_CS_SETUP_PRJ_APP_DIR=${TMP_DC_CS_SETUP_WORKSPACE_DIR}/projects/app
    # 应用项目自启动目录
    local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/boots
    # 应用项目自启动服务器目录
    local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_CDA_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/conda
    local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_SUP_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/supervisor
    local TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DOC_DIR=${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}/docker
    # 应用项目自启动目录
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/init
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_MSQ_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mysql
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_MDB_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mariadb
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_PSQ_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/postgresql
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_MGDB_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/mongodb
    local TMP_DC_CS_SETUP_PRJ_APP_INIT_CH_DIR=${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}/clickhouse
    # 应用项目语种对应目录
    local TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR=${TMP_DC_CS_SETUP_PRJ_APP_DIR}/lang
    local TMP_DC_CS_SETUP_PRJ_APP_PY_DIR=${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}/python
    local TMP_DC_CS_SETUP_PRJ_APP_GO_DIR=${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}/go
    local TMP_DC_CS_SETUP_PRJ_APP_SH_DIR=${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}/shell
    local TMP_DC_CS_SETUP_PRJ_APP_LUA_DIR=${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}/lua
    local TMP_DC_CS_SETUP_PRJ_APP_JV_DIR=${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}/java
    
    # 工具-画图目录
    local TMP_DC_CS_SETUP_DRAWS_DIR=${TMP_DC_CS_SETUP_WORKSPACE_DIR}/projects/draws
    ################################################################################################
    # 应用网站自启动服务器目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_NGX_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_ORT_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_CDY_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DOC_DIR}"

    # 应用网站初始化目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MSQ_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MDB_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_PSQ_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_MGDB_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_CH_DIR}"

    # 应用网站项目语种对应目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_LUA_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_PHP_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_JV_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_WWW_HTML_DIR}"

    # 应用项目自启动服务器目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_CDA_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_SUP_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DOC_DIR}"

    # 应用项目初始化目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MSQ_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MDB_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_PSQ_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_MGDB_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_INIT_CH_DIR}"

    # 应用项目语种对应目录
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_PY_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_GO_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_LUA_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_SH_DIR}"
    path_not_exists_create "${TMP_DC_CS_SETUP_PRJ_APP_JV_DIR}"

    # 工具-画图
    path_not_exists_create "${TMP_DC_CS_SETUP_DRAWS_DIR}"
    ################################################################################################
    # 目录格式化
    # /mountdisk/svr_sync/projects/www/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/www
    path_not_exists_link "${PRJ_DIR}/www/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_WWW_DIR}"
    # /mountdisk/svr_sync/wwwroot/boots/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/www/boots
    path_not_exists_link "${WWW_BOOTS_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_WWW_BOOTS_DIR}"
    # /mountdisk/svr_sync/wwwroot/init/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/www/init
    path_not_exists_link "${WWW_INIT_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_WWW_INIT_DIR}"
    # /mountdisk/svr_sync/wwwroot/lang/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/www/lang
    path_not_exists_link "${WWW_LANG_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_WWW_LANG_DIR}"

    # /mountdisk/svr_sync/projects/app/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/app
    path_not_exists_link "${PRJ_DIR}/app/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_APP_DIR}"
    # /mountdisk/svr_sync/applications/boots/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/app/boots
    path_not_exists_link "${APP_BOOTS_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_APP_BOOTS_DIR}"
    # /mountdisk/svr_sync/applications/init/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/app/init
    path_not_exists_link "${APP_INIT_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_APP_INIT_DIR}"
    # /mountdisk/svr_sync/applications/lang/coder -> /opt/docker_apps/codercom_code-server/4.14.1/workspace/projects/app/lang
    path_not_exists_link "${APP_LANG_DIR}/${TMP_DC_CS_SETUP_IMG_USER}" "" "${TMP_DC_CS_SETUP_PRJ_APP_LANG_DIR}"    
    ################################################################################################
    # 示例项目下载
    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_WWW_HTML_DIR} && \
    git clone https://github.com/dillonzq/LoveIt && \
    git clone https://github.com/h5bp/html5-boilerplate && \
    git clone https://github.com/PanJiaChen/vue-element-admin && \
    git clone https://github.com/zuiidea/antd-admin && \
    git clone https://github.com/bigskysoftware/htmx"

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_WWW_LUA_DIR} && git clone https://github.com/Kong/kong"
    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_WWW_PHP_DIR} && git clone https://github.com/matomo-org/matomo"

    # 手动创建fastapi依赖项目
    mkdir -pv ${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}/fastapi-demo
    cat >${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}/fastapi-demo/requirements.txt<<EOF
fastapi==0.100.0
uvicorn[standard] >=0.12.0,<0.23.0
EOF

    cat >${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}/fastapi-demo/setup.py<<EOF
"""Script to recursively install.

Usage:
  From root directory, execute
  'python setup.py install'.
"""
import os

from setuptools import setup, find_packages

def _process_requirements(requirements_path):
    requires = []
    with open(requirements_path, encoding="utf-8") as file:
        packages = file.read().strip().split('\n')
        for pkg in packages:
            if pkg.startswith('git+ssh'):
                return_code = os.system('pip install {}'.format(pkg))
                assert return_code == 0, 'error, status_code is: {}, exit!'.format(return_code)
            else:
                requires.append(pkg)
    return requires

setup(
    name='foo',
    version='1.0.0',
    author='meyer-net',
    description="just setup",
    packages=find_packages(),
    install_requires=_process_requirements('requirements.txt')
)
EOF

    cat >${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}/fastapi-demo/main.py<<EOF
"""Script to test.

Usage:
  From root directory, execute
  'python main.py'.
"""
#!/usr/bin/env python

from typing import Union

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    """Class representing a person"""
    name: str
    price: float
    is_offer: Union[bool, None] = None

@app.get("/")
def read_root():
    """Function printing python version."""
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    """Function printing python version."""
    return {"item_id": item_id, "q": q}

@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    """Function printing python version."""
    return {"item_name": item.name, "item_id": item_id}
EOF

    cat >${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR}/fastapi-demo/README.md<<EOF
<!--
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
-->

# FastAPI Demo
ReadMe 打不开预览是正常的，请使用带https的域名打开。
本项目仅仅只是测试环境用。

## Contact Us
meyer.cheng

EOF

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_WWW_PY_DIR} && \
    git clone https://github.com/encode/orm && \
    git clone https://github.com/rednafi/fastapi-nano"

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_APP_PY_DIR} && \
    git clone https://github.com/imWildCat/scylla && \
    git clone https://github.com/caronc/apprise"

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_WWW_JV_DIR} && \
    git clone https://github.com/jeecgboot/jeecg-boot && \
    git clone https://github.com/xkcoding/spring-boot-demo && \
    git clone https://github.com/lets-mica/mica && \
    git clone https://github.com/dromara/sureness && \
    git clone https://github.com/justauth/justauth  && \
    git clone https://github.com/halo-dev/halo"

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_APP_SH_DIR} && \
    git clone https://github.com/ohmyzsh/ohmyzsh && \
    git clone https://github.com/binpash/try"

    bash -c "cd ${TMP_DC_CS_SETUP_PRJ_APP_GO_DIR} && \
    git clone https://github.com/gohugoio/hugo && \
    git clone https://github.com/beego/beego && \
    git clone https://github.com/gorilla/mux"
    ################################################################################################
    echo > ${TMP_DC_CS_SETUP_DRAWS_DIR}/empty.dio
    
    # 授权
    sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}

    return $?
}

##########################################################################################################

# 3-规格化软件目录格式
function formal_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'formal' <${TMP_DC_CS_SETUP_IMG_NAME}> 'dirs', hold on please"

    # 开始标准化
    ## 还原 & 创建 & 迁移
    ### 日志
    #### /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_logs() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'logs copy'↓:"

        # 拷贝日志目录
        ## /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:/root/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs ${1}/app >& /dev/null

        ## /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs ${1}/workspace >& /dev/null
        
        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/app
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/workspace
            
        # 查看拷贝列表
        echo_style_text "'|'[app]↓:"
        ls -lia ${1}/app
        echo_style_text "'|'[workspace]↓:"
        ls -lia ${1}/workspace
    }
    soft_path_restore_confirm_create "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}" "_formal_dc_codercom_code-server_cp_logs"

    ### 数据
    #### /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_data() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'data copy'↓:"

        # 拷贝日志目录 Using user-data-dir (~/.local/share/code-server == /home/coder/.local/share/code-server)
        # mkdir -pv ${1}
        # docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR} ${SYNC_DIR}/ >& /dev/null
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT} ${1} >& /dev/null
        
        # 授权 & 查看拷贝列表
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}
        ls -lia ${1}/
    }
    soft_path_restore_confirm_pcreate "${TMP_DC_CS_SETUP_LNK_DATA_DIR}" "_formal_dc_codercom_code-server_cp_data"
    
    ### CONF - ①-1Y：存在配置文件：原路径文件放给真实路径
    #### /mountdisk/data/docker/containers/${CTN_ID}
    local TMP_DC_CS_SETUP_CTN_DIR="${DATA_DIR}/docker/containers/${TMP_DC_CS_SETUP_CTN_ID}"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
    local TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR="${TMP_DC_CS_SETUP_LNK_CONF_DIR}/container"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    function _formal_dc_codercom_code-server_cp_conf() {
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] the 'conf copy'↓:"

        # !!! 有可能未提前生成，故手动创建补足流程
        # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "test -d ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config || mkdir -pv ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config"

        # 1：拷贝配置目录
        ## /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/app
        docker cp -a ${TMP_DC_CS_SETUP_CTN_ID}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config/${TMP_DC_CS_SETUP_IMG_PRJT} ${1}/app >& /dev/null

        # 2：添加python环境
        ## /home/coder/env

        # 授权
        sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${1}/app
        
        # 查看拷贝列表
        ls -lia ${1}/app
        
        ## /mountdisk/data/docker/containers/${CTN_ID} ©&<- /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
        soft_path_restore_confirm_swap "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}" "${TMP_DC_CS_SETUP_CTN_DIR}"
    }
    soft_path_restore_confirm_create "${TMP_DC_CS_SETUP_LNK_CONF_DIR}" "_formal_dc_codercom_code-server_cp_conf"
   
    ### 迁移CONF下LOGS归位
    #### [ 废弃，logs路径会被强制修改未docker root dir对应的数据目录，一旦软连接会被套出多层路径，如下（且修改无效）：
    ##### "LogPath": "/mountdisk/data/docker/containers/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22/mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/4f8b1ca03fe001037e3d701079f094bb5f2a65da089305825546df486c082c22-json.log"
    #### /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log ©&<- /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log
    # soft_path_restore_confirm_move "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CS_SETUP_CTN_ID}-json.log" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CS_SETUP_CTN_ID}-json.log"
    #### ]

    ## 创建链接规则
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] the 'symlink create':↓"
    ### 日志
    #### /opt/docker_apps/codercom_code-server/imgver111111/logs -> /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_LOGS_DIR}" "" "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}"
    #### /opt/docker/logs/codercom_code-server/imgver111111 -> /mountdisk/logs/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_LOGS_MARK}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}"
    #### /mountdisk/logs/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container/${CTN_ID}-json.log
    path_not_exists_link "${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/container/${TMP_DC_CS_SETUP_CTN_ID}-json.log" "" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}/${TMP_DC_CS_SETUP_CTN_ID}-json.log"
    ### 数据
    #### /opt/docker_apps/codercom_code-server/imgver111111/data -> /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_DATA_DIR}" "" "${TMP_DC_CS_SETUP_LNK_DATA_DIR}"
    #### /opt/docker/data/apps/codercom_code-server/imgver111111 -> /mountdisk/data/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_DATA_MARK}/apps/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_DATA_DIR}"
    ### CONF
    #### /opt/docker_apps/codercom_code-server/imgver111111/conf -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${TMP_DC_CS_SETUP_CONF_DIR}" "" "${TMP_DC_CS_SETUP_LNK_CONF_DIR}"
    #### /opt/docker/conf/codercom_code-server/imgver111111 -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111
    path_not_exists_link "${DOCKER_SETUP_DIR}/${DEPLOY_CONF_MARK}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}" "" "${TMP_DC_CS_SETUP_LNK_CONF_DIR}"
    #### /mountdisk/data/docker/containers/${CTN_ID} -> /mountdisk/conf/docker_apps/codercom_code-server/imgver111111/container
    path_not_exists_link "${TMP_DC_CS_SETUP_CTN_DIR}" "" "${TMP_DC_CS_SETUP_LNK_CONF_CTN_DIR}"

    # 预实验部分        
    ## 目录调整完修改启动参数
    echo "${TMP_SPLITER2}"
    echo_style_text "Starting 'inspect change' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 挂载目录(必须停止服务才能修改，否则会无效)
    # docker_change_container_volume_migrate "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_WORK_DIR}:/usr/lib/${TMP_DC_CS_SETUP_APP_MARK} ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/app:/root/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/workspace:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${TMP_DC_CS_SETUP_LNK_DATA_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}:rw,z ${TMP_DC_CS_SETUP_LNK_CONF_DIR}/app:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config" "" $([[ -z "${TMP_DC_CS_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    local TMP_DC_CS_SETUP_CDA_ENVS_DIR=${CONDA_HOME}/envs
    bind_symlink_link_path "TMP_DC_CS_SETUP_CDA_ENVS_DIR"
    local TMP_DC_CS_SETUP_CDA_PKGS_DIR=${CONDA_HOME}/pkgs
    bind_symlink_link_path "TMP_DC_CS_SETUP_CDA_PKGS_DIR"
    local TMP_DC_CS_SETUP_CDA_CONF_DIR=${CONDA_HOME}/etc
    bind_symlink_link_path "TMP_DC_CS_SETUP_CDA_CONF_DIR"

    docker_change_container_volume_migrate "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_WORK_DIR}:/usr/lib/${TMP_DC_CS_SETUP_APP_MARK} ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/app:/root/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${TMP_DC_CS_SETUP_LNK_DATA_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}:rw,z ${TMP_DC_CS_SETUP_LNK_LOGS_DIR}/workspace:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/coder-logs:rw,z ${SYNC_DIR}/${TMP_DC_CS_SETUP_IMG_USER}/projects:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/projects:rw,z ${TMP_DC_CS_SETUP_LNK_CONF_DIR}/app:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.config/${TMP_DC_CS_SETUP_IMG_PRJT} ${CONDA_HOME}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda ${TMP_DC_CS_SETUP_CDA_ENVS_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda/envs:rw,z ${TMP_DC_CS_SETUP_CDA_PKGS_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda/pkgs:rw,z ${TMP_DC_CS_SETUP_CDA_CONF_DIR}:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda/etc:rw,z" "" $([[ -z "${TMP_DC_CS_SETUP_IMG_SNAP_TYPE}" ]] && echo true)
    
    return $?
}

##########################################################################################################

# 4-设置软件
function conf_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'configuration' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 开始配置

    return $?
}

##########################################################################################################

# 5-测试软件
function test_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}
    
    echo_style_wrap_text "Starting 'test' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    # 实验部分
    ## 1：检测启停
    docker container stop ${TMP_DC_CS_SETUP_CTN_ID}
    docker container start ${TMP_DC_CS_SETUP_CTN_ID}

    return $?
}

##########################################################################################################

# 6-启动后检测脚本
function boot_check_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    # 实验部分
    echo_style_wrap_text "Starting 'boot check' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"

    if [ -n "${TMP_DC_CS_SETUP_CTN_PORT}" ]; then
        echo_style_text "[View] the 'container visit'↓:"
        curl -s http://localhost:${TMP_DC_CS_SETUP_CTN_PORT}
        echo

        # 授权iptables端口访问
        echo "${TMP_SPLITER2}"
        echo_style_text "[View] echo the 'port'(<${TMP_DC_CS_SETUP_CTN_PORT}>) to iptables:↓"
        echo_soft_port "TMP_DC_CS_SETUP_OPN_PORT"
        
        # 生成web授权访问脚本
        # echo_web_service_init_scripts "codercom_code-server${LOCAL_ID}" "codercom_code-server${LOCAL_ID}-webui.${SYS_DOMAIN}" ${TMP_DC_CS_SETUP_OPN_PORT} "${LOCAL_HOST}"
    fi
    
    # 授权开机启动
    echo "${TMP_SPLITER2}"
    echo_style_text "[View] echo the 'supervisor startup conf'↓:"
    # echo_startup_supervisor_config "${TMP_DC_CS_SETUP_IMG_MARK_NAME}" "${TMP_DC_CS_SETUP_DIR}" "systemctl start ${TMP_DC_CS_SETUP_IMG_MARK_NAME}.service" "" "999" "" "" false 0
    echo_startup_supervisor_config "${TMP_DC_CS_SETUP_IMG_MARK_NAME}" "${TMP_DC_CS_SETUP_DIR}" "bin/${TMP_DC_CS_SETUP_IMG_MARK_NAME} start"
    
    # 结束
    exec_sleep 10 "Boot <${TMP_DC_CS_SETUP_IMG_NAME}> over, please checking the setup log, this will stay [%s] secs to exit"
}

##########################################################################################################

# 7-1 下载扩展/驱动/插件
function down_ext_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'download' <${TMP_DC_CS_SETUP_IMG_NAME}> 'exts', hold on please"
    
    # 安装python环境插件
    echo_style_text "'|'Starting 'download ext' - [pip], hold on please"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install python"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "apt-get -y install python3-pip"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "pip --version" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "pip install --upgrade pip" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "pip install --upgrade setuptools" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "pip install playwright==1.30.0" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "python3 --version" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    
    # 静默安装 conda
    echo_style_text "${TMP_SPLITER2}"
    echo_style_text "'|'Starting 'integration ext' - [conda], hold on please"
    ## ??? 检测外部conda是否存在
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && /bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p ~/.local/share/conda && rm Miniconda3-latest-Linux-x86_64.sh' "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # 同步新增的bashrc内容
    ## 提取行号参考：https://blog.csdn.net/Jerry_1126/article/details/85800485
    local TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA=$(su - conda -c "pwd")
    local TMP_DC_CS_SETUP_SUPPORT_CONDA_BASHRC_LINE_START=$(cat ${TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA}/.bashrc | grep -naE "^# >>> conda initialize >>>$" | cut -d':' -f1)
    local TMP_DC_CS_SETUP_SUPPORT_CONDA_BASHRC_LINE_END=$(cat ${TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA}/.bashrc | grep -naE "^# <<< conda initialize <<<$" | cut -d':' -f1)
    local TMP_DC_CS_SETUP_SUPPORT_CONDA_BASH_RC=$(cat ${TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA}/.bashrc | sed -n "${TMP_DC_CS_SETUP_SUPPORT_CONDA_BASHRC_LINE_START},${TMP_DC_CS_SETUP_SUPPORT_CONDA_BASHRC_LINE_END}p" | sed "s@${CONDA_HOME}@~/.local/share/conda@g")
    local TMP_DC_CS_SETUP_SUPPORT_CONDA_BOOT_RC_SH=$(cat <<EOF
cat >> .bashrc <<'${EOF_TAG}'

${TMP_DC_CS_SETUP_SUPPORT_CONDA_BASH_RC}
${EOF_TAG}

mkdir .conda
cat >> .conda/environments.txt <<'${EOF_TAG}'
$(cat ${TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA}/.conda/environments.txt | sed "s@${CONDA_HOME}@~/.local/share/conda@g")
${EOF_TAG}

cat >> .condarc <<'${EOF_TAG}'
$(cat ${TMP_DC_CS_SETUP_SUPPORT_HOME_CONDA}/.condarc)
${EOF_TAG}
EOF
)

    # 输出环境变量(软链接确保内部路径不会冲突)
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_SUPPORT_CONDA_BOOT_RC_SH}" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "ln -sf ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda ${CONDA_HOME}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/conda ${CONDA_HOME}" 
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "mkdir -pv .conda && touch .conda/environments.txt" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "ls -lia .local/share/conda/envs | awk 'NR>4{print \$NF}' | xargs -I {} echo \"~/.local/share/conda/envs/{}\" >> .conda/environments.txt" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # 给fastapi-demo添加环境
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "cp -r ${CONDA_HOME}/envs/pyenv37 ~/projects/www/lang/python/fastapi-demo/.conda && echo ~/projects/www/lang/python/fastapi-demo/.conda >> environments.txt" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    
    # 调整基本配置
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'cd ~/.local/share/conda && condabin/conda update -y conda' "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'cd ~/.local/share/conda && condabin/conda config --add channels microsoft' "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'cd ~/.local/share/conda && condabin/conda config --add channels conda-forge' "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'cd ~/.local/share/conda && condabin/conda config --add channels bioconda' "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" 'cd ~/.local/share/conda && condabin/conda config --set auto_activate_base false' "" "${TMP_DC_CS_SETUP_IMG_USER}"
   
    return $?
}

# 7-2 安装与配置扩展/驱动/插件
function setup_ext_dc_codercom_code-server() {
    cd ${TMP_DC_CS_SETUP_DIR}

    echo_style_wrap_text "Starting 'install' <${TMP_DC_CS_SETUP_IMG_NAME}> 'exts', hold on please"

    # 通用
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension natizyskunk.sftp" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension xyz.local-history" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-ceintl.vscode-language-pack-zh-hans" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # JAVA
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension pleiades.java-extension-pack-jdk" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension redhat.java" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vscjava.vscode-java-debug" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vscjava.vscode-maven" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vscjava.vscode-java-pack" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension redhat.vscode-rsp-ui" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension esbenp.prettier-vscode" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vscjava.vscode-spring-boot-dashboard" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vscjava.vscode-spring-initializr" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension pivotal.vscode-boot-dev-pack" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # PYTHON
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension magicstack.magicpython" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-pyright.pyright" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-python.anaconda-extension-pack" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-python.pylint" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension njpwerner.autodocstring" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension kevinrose.vsc-python-indent" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension almenon.arepl" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # PHP
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension devsense.phptools-vscode" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension bmewburn.vscode-intelephense-client" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # JAVASCRIPT
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension dbaeumer.vscode-eslint" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension eg2.vscode-npm-script" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension octref.vetur" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension vue.volar" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension dsznajder.es7-react-js-snippets" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension kisstkondoros.vscode-gutter-preview" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension formulahendry.auto-close-tag" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ecmel.vscode-html-css" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension mrcrowl.easy-less" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension syler.sass-indented" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension xabikos.javascriptsnippets" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension techer.open-in-browser" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension hookyqr.beautify" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension formulahendry.auto-rename-tag" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension christian-kohler.npm-intellisense" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension streetsidesoftware.code-spell-checker" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension msjsdiag.debugger-for-edge" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension msjsdiag.debugger-for-chrome" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension firefox-devtools.vscode-firefox-debug" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # SHELL
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension foxundermoon.shell-format" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension timonwong.shellcheck" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # 小语种
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ex-codes.pine-script-syntax-highlighter" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension juanblanco.solidity" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension yzhang.markdown-all-in-one" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension shd101wyy.markdown-preview-enhanced" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension redhat.vscode-yaml" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # !!!docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension sumneko.lua" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    
    # GIT
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension knisterpeter.vscode-github" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension github.github-vscode-theme" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension cschleiden.vscode-github-actions" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    
    # 远程工具
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ritwickdey.liveserver" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-vscode.live-server" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-vscode-remote.remote-ssh" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # 主题样式
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension pkief.material-product-icons" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension pkief.material-icon-theme" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension ms-vscode.theme-materialkit" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension dez64ru.macos-modern-theme" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    # 辅助工具
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension hediet.vscode-drawio" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension mutable-ai.mutable-ai" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension tabnine.tabnine-vscode" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension kiteco.kite" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension cweijan.vscode-office" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension dendron.dendron-paste-image" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension rangav.vscode-thunder-client" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension humao.rest-client" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension cweijan.vscode-database-client2" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension formulahendry.code-runner" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension cweijan.vscode-redis-client" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension christian-kohler.path-intellisense" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension alefragnani.project-manager" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension adpyke.codesnap" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension eamodio.gitlens" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension mhutchie.git-graph" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    # docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension oderwat.indent-rainbow" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension markwylde.vscode-filesize" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension wix.vscode-import-cost" "" "${TMP_DC_CS_SETUP_IMG_USER}"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "${TMP_DC_CS_SETUP_IMG_PRJT} --install-extension wakatime.vscode-wakatime" "" "${TMP_DC_CS_SETUP_IMG_USER}"

    return $?
}

##########################################################################################################

# 8-重新配置（有些软件安装完后需要重新配置）
function reconf_dc_codercom_code-server()
{
    cd ${TMP_DC_CS_SETUP_DIR}
	
    echo_style_wrap_text "Starting 'reconf' <${TMP_DC_CS_SETUP_IMG_NAME}>, hold on please"
    
    # 开始配置
    ## 修改默认主题颜色
    # local TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH="${TMP_DC_CS_SETUP_LNK_DATA_DIR}/.local/share/${TMP_DC_CS_SETUP_IMG_PRJT}/User/settings.json"
    local TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH="${TMP_DC_CS_SETUP_LNK_DATA_DIR}/User/settings.json"
    if [ ! -f ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH} ]; then
        echo "{}" > ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH}
    fi
    
    local TMP_DC_CS_SETUP_USER_SETTINGS_JSON=$(cat ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH})

    # /home/coder/.local/share/code-server/User/settings.json
    # jq '."workbench.colorTheme"="Visual Studio Dark"' ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH}
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."workbench.colorTheme"' '"Material"'
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."workbench.iconTheme"' '"material-icon-theme"'
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."workbench.productIconTheme"' '"macos-modern"'
    ## 通用
    ### GIT
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."git.enableSmartCommit"' "true"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."git.autofetch"' "true"
    ### 每次保存的时候自动格式化
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."editor.formatOnSave"' "true"
    ### 设定默认代码格式化器(全局或指定语言)
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."editor.defaultFormatter"' '"esbenp.prettier-vscode"'
    # change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[javascript]"."editor.defaultFormatter"' '"esbenp.prettier-vscode"'
    ### 设定ESLint只对javascript、typescript以及javascrpitreact进行代码格式化
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[javascript]"."editor.formatOnSave"' "false"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[javascriptreact]"."editor.formatOnSave"' "false"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[typescript]"."editor.formatOnSave"' "false"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[typescriptreact]"."editor.formatOnSave"' "false"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[html]"."editor.formatOnSave"' "false"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[vue]"."editor.formatOnSave"' "false"

    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."[shellscript]"."editor.defaultFormatter"' '"foxundermoon.shell-format"'

    ## javascript
    ### 让函数(名)和后面的括号之间加个空格
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."javascript.format.insertSpaceBeforeFunctionParenthesis"' "true"

    ## eslint
    ### 启用
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."eslint.enable"' "true"
    ### 使用了eslint，取消vscode原有的验证。否则会失效
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."javascript.validate.enable"' "false"
    ### 使用eslint来fix，包括格式化会自动fix和代码质量检查会给出错误提示
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."editor.codeActionsOnSave"."source.fixAll.eslint"' "true"

    ## easyless
    ### 是否压缩
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."less.compile"."compress"' "false"
    ### 是否开启SourceMap，用于查看文件的行数
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."less.compile"."sourceMap"' "false"
    ### 输出路径
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."less.compile"."out"' '"${workspaceRoot}\\css\\"'
    ### 输出文件的后缀
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."less.compile"."outExt"' '".css"'

    ## code-runner
    ### 
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."code-runner.runInTerminal"' "true"
    ### 
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."code-runner.saveFileBeforeRun"' "true"

    ## prettier
    ### 让prettier使用eslint的代码格式进行校验 
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."prettier.eslintIntegration"' "true"
    ### 代码末尾添加分号
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."prettier.semi"' "true"
    ### 使用单引号替代双引号 
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."prettier.singleQuote"' "true"
    ### 箭头函数添加括号
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."prettier.arrowParents"' '"always"'
    ### 在对象或数组最后一个元素后面是否加逗号 
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."prettier.trailingComma"' '"none"'

    ## path-intellisense
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."path-intellisense.mappings"."@"' '"${workspaceRoot}/src"'

    ### java
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."rsp-ui.rsp.java.home"' "\"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/java/17\""
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."spring-boot.ls.java.home"' "\"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/java/17\""
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."java.import.gradle.home"' "\"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/gradle/latest\""
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."maven.terminal.customEnv"' "[{\"environmentVariable\": \"JAVA_HOME\", \"value\": \"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/java/17\"}]"

    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."bash"' "{\"path\": \"bash\"}"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."zsh"' "{\"path\": \"zsh\"}"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."fish"' "{\"path\": \"fish\"}"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."tmux"' "{\"path\": \"tmux\", \"icon\": \"terminal-tmux\"}"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."pwsh"' "{\"path\": \"pwsh\", \"icon\": \"terminal-powershell\"}"
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."terminal.integrated.profiles.linux"."JavaSE-17"' "{\"overrideName\": true, \"path\": \"bash\", \"args\": [\"--rcfile\", \"~/.bashrc_jdkauto\"], \"env\": {\"PATH\": \"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/java/17/bin:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/maven/latest/bin:${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/gradle/latest/bin:\${env:PATH}\", \"JAVA_HOME\": \"${TMP_DC_CS_SETUP_CTN_WORK_DIR}/.local/share/code-server/User/globalStorage/pleiades.java-extension-pack-jdk/java/17\"}}"

    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."java.debug.settings.hotCodeReplace"' '"auto"'
    change_json_node_item "TMP_DC_CS_SETUP_USER_SETTINGS_JSON" '."boot-java.rewrite.reconcile"' "true"

    echo "${TMP_DC_CS_SETUP_USER_SETTINGS_JSON}" | jq > ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH}

    # 授权
    sudo chown -R ${TMP_DC_CS_SETUP_CTN_UID}:${TMP_DC_CS_SETUP_CTN_GID} ${TMP_DC_CS_SETUP_USER_SETTINGS_JSON_PATH}
    
    # 调整系统配置
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf"
    docker_bash_channel_exec "${TMP_DC_CS_SETUP_CTN_ID}" "sysctl -p"

	return $?
}

##########################################################################################################

# x3-执行步骤
#    参数1：启动后的进程ID
#    参数2：最终启动端口
#    参数3：最终启动版本
#    参数4：最终启动命令
#    参数5：最终启动参数
function exec_step_dc_codercom_code-server() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CS_SETUP_CTN_ID="${1}"
    # local TMP_DC_CS_SETUP_PS_SID="${TMP_DC_CS_SETUP_CTN_ID:0:12}"
    local TMP_DC_CS_SETUP_CTN_PORT="${2}"
    # imgver111111/imgver111111_v1670000000
    local TMP_DC_CS_SETUP_CTN_VER="${3}"
    local TMP_DC_CS_SETUP_CTN_CMD="${4}"
    local TMP_DC_CS_SETUP_CTN_ARGS="${5}"
    local TMP_DC_CS_SETUP_CTN_WORK_DIR="$(echo "${5}" | grep -oP "(?<=--workdir\=)[^\s]+")"
    if [ -z "${TMP_DC_CS_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CS_SETUP_CTN_WORK_DIR=$(docker container inspect --format '{{.Config.WorkingDir}}' ${1})
    fi

    # 默认取进入时的目录
    if [ -z "${TMP_DC_CS_SETUP_CTN_WORK_DIR}" ]; then
        TMP_DC_CS_SETUP_CTN_WORK_DIR=$(docker_bash_channel_exec "${1}" "pwd" "" "${TMP_DC_CS_SETUP_IMG_USER}")
    fi

    # 获取授权用户的UID/GID
    local TMP_DC_CS_SETUP_CTN_UID=$(docker_bash_channel_exec "${1}" "id -u ${TMP_DC_CS_SETUP_IMG_USER}")
    local TMP_DC_CS_SETUP_CTN_GID=$(docker_bash_channel_exec "${1}" "id -g ${TMP_DC_CS_SETUP_IMG_USER}")
    
    # 软件内部标识版本（$3已返回该版本号，仅测试选择5.7.42的场景）
    local TMP_DC_CS_SETUP_SOFT_VER=$(docker_bash_channel_exec "${1}" "code-server -v | awk '{print \$NF}'")

    ## 统一编排到的路径
    local TMP_DC_CS_SETUP_DIR=${DOCKER_APP_SETUP_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_LOGS_DIR=${DOCKER_APP_LOGS_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_DATA_DIR=${DOCKER_APP_DATA_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}
    local TMP_DC_CS_SETUP_LNK_CONF_DIR=${DOCKER_APP_CONF_DIR}/${TMP_DC_CS_SETUP_IMG_MARK_NAME}/${TMP_DC_CS_SETUP_CTN_VER}

    ## 统一标记名称(存在于安装目录的真实名称)
    local TMP_DC_CS_SETUP_APP_MARK="code-server"

    ## 安装后的真实路径（此处依据实际路径名称修改）
    local TMP_DC_CS_SETUP_WORK_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_WORK_MARK}
    local TMP_DC_CS_SETUP_WORKSPACE_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_WORKSPACE_MARK}
    local TMP_DC_CS_SETUP_LOGS_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_LOGS_MARK}
    local TMP_DC_CS_SETUP_DATA_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_DATA_MARK}
    local TMP_DC_CS_SETUP_CONF_DIR=${TMP_DC_CS_SETUP_DIR}/${DEPLOY_CONF_MARK}
    
    echo_style_wrap_text "Starting 'execute step' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_CTN_VER}]('${TMP_DC_CS_SETUP_CTN_ID}'), hold on please"

    set_env_dc_codercom_code-server

    setup_dc_codercom_code-server

    formal_dc_codercom_code-server

    conf_dc_codercom_code-server

    test_dc_codercom_code-server

    down_ext_dc_codercom_code-server
    setup_ext_dc_codercom_code-server

    boot_check_dc_codercom_code-server

    reconf_dc_codercom_code-server
    
    # 结束
    exec_sleep 30 "Install <${TMP_DC_CS_SETUP_IMG_NAME}> over, please checking the setup log, this will stay [%s] secs to exit"

    return $?
}

##########################################################################################################

# x2-简略启动，获取初始化软件（形成启动后才可抽取目录信息）
#    参数1：镜像名称，例 codercom/code-server
#    参数2：镜像版本，例 latest
#    参数3：启动命令，例 /bin/sh
#    参数4：启动参数，例 --volume /etc/localtime:/etc/localtime
#    参数5：快照类型(还原时有效)，例 image/container/dockerfile
#    参数6：快照来源，例 snapshot/clean/hub/commit，默认snapshot
function boot_build_dc_codercom_code-server() {
    # 变量覆盖特性，其它方法均可读取
    ## 执行传入参数
    local TMP_DC_CS_SETUP_IMG_NAME="${1}"
    local TMP_DC_CS_SETUP_IMG_MARK_NAME="${1/\//_}"
    local TMP_DC_CS_SETUP_IMG_VER="${2}"
    local TMP_DC_CS_SETUP_CTN_ARG_CMD="${3}"
    local TMP_DC_CS_SETUP_CTN_ARGS="${4}"
    local TMP_DC_CS_SETUP_IMG_SNAP_TYPE="${5}"
    local TMP_DC_CS_SETUP_IMG_STORE="${6}"

    echo_style_wrap_text "Starting 'build container' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_IMG_VER}], hold on please"

    # 设置密码
    ## 面板密码
    local TMP_DC_CS_SETUP_GUI_PASSWD=$(console_input "$(rand_simple_passwd 'cs.gui' 'ide' "${TMP_DC_CS_SETUP_IMG_VER}")" "Please sure your 'ide gui' <access password>" "y")
    ## SUDO密码
    local TMP_DC_CS_SETUP_SUDO_PASSWD=$(console_input "$(rand_passwd 'cs.sudo' 'ide' "${TMP_DC_CS_SETUP_IMG_VER}")" "Please sure your 'ide sudo' <terminal password>" "y")
    
    ## 标准启动参数
    local TMP_DC_CS_SETUP_PRE_ARG_PORTS="-p ${TMP_DC_CS_SETUP_OPN_PORT}:${TMP_DC_CS_SETUP_INN_PORT}"
    local TMP_DC_CS_SETUP_PRE_ARG_NETWORKS="--network=${DOCKER_NETWORK}"
    local TMP_DC_CS_SETUP_PRE_ARG_ENVS="--hostname=sandbox.${TMP_DC_CS_SETUP_IMG_USER} --env=TZ=Asia/Shanghai --privileged=true --expose ${TMP_DC_CS_SETUP_INN_PORT} --env=PASSWORD=${TMP_DC_CS_SETUP_GUI_PASSWD} --env=SUDO_PASSWORD=${TMP_DC_CS_SETUP_SUDO_PASSWD}"
    local TMP_DC_CS_SETUP_PRE_ARG_MOUNTS="--volume=/etc/localtime:/etc/localtime:ro --volume=$(which jq):/usr/bin/jq --volume=$(which yq):/usr/bin/yq --volume=$(which gum):/usr/bin/gum --volume=$(which pup):/usr/bin/pup --volume=/run/docker.sock:/var/run/docker.sock --volume=$(which docker):/usr/bin/docker --volume=$(which docker-compose):/usr/bin/docker-compose"
    local TMP_DC_CS_SETUP_PRE_ARGS="--name=${TMP_DC_CS_SETUP_IMG_MARK_NAME}_${TMP_DC_CS_SETUP_IMG_VER} ${TMP_DC_CS_SETUP_PRE_ARG_PORTS} ${TMP_DC_CS_SETUP_PRE_ARG_NETWORKS} --restart=always ${TMP_DC_CS_SETUP_PRE_ARG_ENVS} ${TMP_DC_CS_SETUP_PRE_ARG_MOUNTS}"

    # !!! 默认包含用户（可能内部相关文件夹未指定该用户，从而引发permission错误）
    # --env=USER=coder

    # 参数覆盖, 镜像参数覆盖启动设定
    echo_style_text "[Container] 'pre' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "[Container] 'ctn' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_CTN_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"
    
    echo "${TMP_SPLITER3}"
    echo_style_text "Starting 'combine container' <${TMP_DC_CS_SETUP_IMG_NAME}>:[${TMP_DC_CS_SETUP_IMG_VER}] boot args, hold on please"
    docker_image_args_combine_bind "TMP_DC_CS_SETUP_PRE_ARGS" "TMP_DC_CS_SETUP_CTN_ARGS"
    echo_style_text "[Container] 'combine' args && cmd↓:"
    echo "Args：${TMP_DC_CS_SETUP_PRE_ARGS:-None}"
    echo "Cmd：${TMP_DC_CS_SETUP_CTN_ARG_CMD:-None}"

    # 开始启动
    docker_image_boot_print "${TMP_DC_CS_SETUP_IMG_NAME}" "${TMP_DC_CS_SETUP_IMG_VER}" "${TMP_DC_CS_SETUP_CTN_ARG_CMD}" "${TMP_DC_CS_SETUP_PRE_ARGS}" "" "exec_step_dc_codercom_code-server"
    
    return $?
}

##########################################################################################################

# x1-下载/安装/更新软件
function check_setup_dc_codercom_code-server() {
	# 当前路径（仅记录）
    local TMP_DC_CS_CURRENT_DIR=$(pwd)

    echo_style_wrap_text "Checking 'install' <${1}>, hold on please"

    # 重装/更新/安装
    soft_docker_check_choice_upgrade_action "${TMP_DC_CS_SETUP_IMG_REPO}" "boot_build_dc_codercom_code-server"

    return $?
}

##########################################################################################################

# 安装主体
soft_setup_basic "${TMP_DC_CS_DISPLAY_TITLE}" "check_setup_dc_codercom_code-server"