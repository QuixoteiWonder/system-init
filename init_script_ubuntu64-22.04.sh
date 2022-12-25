#!/bin/bash
echo "主机环境：ubuntu64-22.04。"
echo "本脚本目录结构：
ubuntu@ideaMachine:/mnt/share/system-init$ tree
.
├── init_script.sh
├── Language
     ├── go1.19.4.linux-amd64.tar.gz
     └── Python-3.9.16.tar.xz
├── profile
     ├── env
          └── etc_profile.d_custom_env.sh
     ├── git
          └── HOME_gitconfig
     ├── net
          └── etc_apt_sources.list
     └── vim
         └── etc_vim_vimrc
└── Tool
    ├── goland-2022.3.tar.gz
    ├── jetbrains_settings.zip
    ├── pycharm-professional-2022.3.tar.gz
    └── sublime_text.tar.gz"
echo "脚本将/opt目录作为工作目录。并在家目录下创建名为workspace指向/opt/src 的软链接。"
echo "由于文件包较大, 可通过 VMware -> 虚拟机 -> 虚拟机设置 -> 选项 -> 共享文件夹 上传本文件到虚拟机。"
echo "设置完毕后，命令行执行 vmware-hgfsclient && sudo vmhgfs-fuse .host:/ /mnt && sudo ls /mnt -o allow_other 即可查看共享文件"
echo "最后切换普通用户目录，执行 bash /mnt/path/to/system-init/init-script.sh 以完成安装。"
echo "完成安装后，请重启。"

# 获取脚本所在目录
BASE_DIR=`cd $( dirname $0 ); pwd`
# 获取当前用户密码 
read -p "[sudo] password for $USER: " USER_PWD
# software和language安装包是否已上传[y/n] [default: no]？
read -p "network & sshd & common-instruction & workspace configure? [y/n] [default: no] " NET_FLAG
read -p "software & language install? [y/n] [default: no] " SOFT_FLAG
read -p "Are you sure to continue? [y/n]: " INPUT

function continue_check() {
	case $INPUT in
        [yY]*)
                ;;
        [nN]*)
                exit
                ;;
        *)
                echo "Just enter y or n, please."
                exit
                ;;
	esac
	unset INPUT
}

continue_check

function cmd_highlight() {
	# 将传入的命令高亮显示
	echo "excute:"

	# 改变控制台输出颜色
	if [[ $1 =~ ^sudo$ ]]; then
		echo -e "\033[36m  $* \033[0m"
		echo $USER_PWD | sudo -S $*
	else
		echo -e "\033[32m  $* \033[0m"
		$*
	fi

	# if [[ $? -ne 1 ]]; then
	# 	echo "catch error:"
	# 	echo -e "\033[31m$* \033[0m"
	# fi
}


function notice() {
	echo "notice:"
	echo -e "\033[33m  $* \033[0m" 
}



# DOCKER. TODO...
function docker_install() {
	# 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
	cmd_highlight sudo apt install -y ca-certificates curl gnupg lsb-release

	# 2. Add Docker’s official GPG key:
	cmd_highlight sudo mkdir -p /etc/apt/keyrings
	# cmd_highlight curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	cmd_highlight curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# 3. Use the following command to set up the repository:

	# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# 4. Update the apt package index:
	cmd_highlight sudo chmod a+r /etc/apt/keyrings/docker.gpg
	cmd_highlight sudo apt update

	# 5. Install the latest version Docker Engine, containerd, and Docker Compose:
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

	notice "Verify that the Docker Engine installation is successful by running the hello-world image: sudo docker run hello-world"
}



function network_configure() {
	# 清华源
	# https://blog.csdn.net/ZZhangYajuan/article/details/128137630
	cmd_highlight sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
	cmd_highlight sudo cp -f ${BASE_DIR}/profile/net/etc_apt_sources.list /etc/apt/sources.list
	cmd_highlight sudo apt install apt-transport-https ca-certificates
	cmd_highlight sudo apt update
}

function ssh_configure() {
	# 配置完毕后可远程xshell登录本主机
	cmd_highlight sudo apt install -y openssh-server
}


function common_instruction_install() {
	# 常用Linux命令安装
	cmd_highlight sudo apt install -y vim net-tools tree silversearcher-ag tig lrzsz

	# vim 
	cmd_highlight sudo cp /etc/vim/vimrc /etc/vim/vimrc.bak
	cmd_highlight sudo cp -f ${BASE_DIR}/profile/vim/etc_vim_vimrc /etc/vim/vimrc

	# git configure
	cmd_highlight cp -f ${BASE_DIR}/profile/git/HOME_gitconfig ~/.gitconfig
	# 生成密钥对
	cmd_highlight mkdir ~/.ssh
	cmd_highlight ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa -C \"reidlv@126.com\"
	cmd_highlight cat ~/.ssh/id_rsa.pub
	notice "请复制上方公钥到git服务端"
}


# 配置工作路径
function workspace_configure() {
	# src 存放源代码
	# Tool 存放开发工具等第三方或自己编写的软件
	# Language python golang等编程语言的安装目录
	# bin 存放常用软件的快捷启动符号链接
	cmd_highlight mkdir ~/src
	cmd_highlight mkdir ~/Tool
	cmd_highlight mkdir ~/Language
	cmd_highlight mkdir ~/bin

	cmd_highlight sudo mv ~/src /opt/
	cmd_highlight sudo mv ~/Tool /opt/
	cmd_highlight sudo mv ~/Language /opt/
	cmd_highlight sudo mv ~/bin /opt/

   	                                             
   	cmd_highlight sudo cp -f ${BASE_DIR}/profile/env/etc_profile.d_custom_env.sh /etc/profile.d/custom_env.sh
	cmd_highlight ln -s /opt/src ~/workspace
}



function software_install() {
	# sublime
	cmd_highlight tar -xzf ${BASE_DIR}/Tool/sublime_text*.tar.gz -C /opt/Tool/
	cmd_highlight ln -s /opt/Tool/sublime_text*/sublime_text /opt/bin/subl
	notice "命令行输入subl可启动sublime_text"
	cmd_highlight cat ${BASE_DIR}/activationCode/sublime_text4
	notice "查看上方激活码"

	# pycharm
	cmd_highlight tar -xzf ${BASE_DIR}/Tool/pycharm*.tar.gz -C /opt/Tool/
	cmd_highlight ln -s /opt/Tool/pycharm*/bin/pycharm.sh /opt/bin/pycharm
	notice "命令行输入pycharm可启动pycharm"
	notice "settings.zip under the path: ${BASE_DIR}/workspace/system-init/profile/jetbrains/pycharm/"
	cmd_highlight cat ${BASE_DIR}/activationCode/jet_brains
	notice "查看上方激活码"

	# goland
	cmd_highlight tar -xzf ${BASE_DIR}/Tool/goland*.tar.gz -C /opt/Tool/
	cmd_highlight ln -s /opt/Tool/GoLand*/bin/goland.sh /opt/bin/goland
	notice "命令行输入goland可启动goland"
	notice "settings.zip under the path: ${BASE_DIR}/workspace/system-init/profile/jetbrains/goland/"

	cmd_highlight cat ${BASE_DIR}/activationCode/jet_brains
	notice "查看上方激活码"
}


function language_install() {
	# golang
	cmd_highlight tar -xzf ${BASE_DIR}/Language/go*.tar.gz -C /opt/Language/
	cmd_highlight ln -s /opt/Language/go/bin/* /opt/bin/
	notice "Verify that you've installed Go by opening a command prompt and typing: go version"

	# python
	# https://blog.csdn.net/qq_27825451/article/details/100034135
	
	# 安装源码编译时所需依赖
	cmd_highlight sudo apt install -y gcc make cmake build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev
	# 解压源码
	# 获取python安装包名称：Python-3.9.16
	BASENAME_PY=`basename ${BASE_DIR}/Language/Python*.tar.xz .tar.xz`

	cmd_highlight tar -xf ${BASE_DIR}/Language/${BASENAME_PY}.tar.xz -C /opt/Language/
	cmd_highlight mv /opt/Language/${BASENAME_PY} /opt/Language/python_source_code_tmp
	cmd_highlight mkdir /opt/Language/${BASENAME_PY}


	cmd_highlight cd /opt/Language/python_source_code_tmp
	
	cmd_highlight make clean && make distclean

	cmd_highlight ./configure --prefix=/opt/Language/${BASENAME_PY} --enable-optimizations
	cmd_highlight make && make install

	# python(python3.9.16) version num: like: 3.9
	VERSION_NUM_PY=`echo ${BASENAME_PY} | awk -F '-' '{print $2}' | awk -F '.' '{print $1"."$2}'`

	cmd_highlight ln -s /opt/Language/${BASENAME_PY}/bin/python${VERSION_NUM_PY} /opt/bin/python${VERSION_NUM_PY}
	cmd_highlight ln -s /opt/Language/${BASENAME_PY}/bin/pip${VERSION_NUM_PY} /opt/bin/pip${VERSION_NUM_PY}
	cmd_highlight cd -
	cmd_highlight rm -rf /opt/Language/python_source_code_tmp
	unset BASENAME_PY
	unset VERSION_NUM_PY
	notice "Verify that you've installed Python and Pip by opening a command prompt and typing: python${VERSION_NUM_PY} and pip${VERSION_NUM_PY}"
 


}

function content_recursive_replace() {
	# 将指定路径先所有子文件中的指定内容替换为新内容
	# $1: specify path
	# $2: old string
	# $3: replace string

	# 若变量为路径，需提前转义
	old=$( echo $2 | sed 's/\//\\\//g' )
	new=$( echo $3 | sed 's/\//\\\//g' )

	cd $1

	for fname in `ag $2 | awk -F ':' '{print $1}' | sort -u`
	do
		# 原文件备份
		cmd_highlight cp -f $fname $fname.bak
		cmd_highlight sed -i "s/$old/$new/g" $fname
	done

	cd -
	unset fname
	unset old
	unset new
}


function adapt_new_pyvenv_path() {
	notice "软连接路径会导致修改不成功，请确保参数为真实路径"
	# $1: origin venv absolute path. like: /old-path/project/venv-oldname
	# $2: new venv absolute path. like:    /new-path/project/venv-newname
	content_recursive_replace $1 $1 $2

	cmd_highlight mv $1 $2
}


function adapt_new_python_language_path() {
	adapt_new_pyvenv_path $1 $2
}


function main() {
	if [[ $NET_FLAG =~ ^[yY].* ]]; then
		network_configure
		ssh_configure
		common_instruction_install
		docker_install
		workspace_configure
	fi
	if [[ $SOFT_FLAG =~ ^[yY].* ]]; then
		software_install
		language_install
	fi
}

# main
docker_install
