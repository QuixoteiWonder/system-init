##### 这是一个快速搭建Ubuntu下基本工作环境的脚本。

可以按照使用习惯快速在一台空白系统上搭建起常用的工作环境。

其功能包含常用命令&开发语言&IDE的安装。

###### 结构目录：

```shell
$:~/system-init$ tree
.
├── init_script_ubuntu64-22.04.sh              # 启动脚本
├── activationCode                             # 存放各种所需激活码
│   ├── jet_brains
│   └── sublime_text4

├── profile                                    # 存放配置文件
│   ├── env
│   │   └── etc_profile.d_custom_env.sh
│   ├── git
│   │   └── HOME_gitconfig
│   ├── net
│   │   └── etc_apt_sources.list
│   └── vim
│       └── etc_vim_vimrc
├── README.md
├── Language                                   # 存放各语言的安装包
└── Tool                                       # 存放IDE安装包
```

###### 启动命令：

`bash init_script_ubuntu64-22.04.sh`

###### 注意事项：

若为虚拟机安装
由于本脚本文件包较大, 可通过
` VMware -> 虚拟机 -> 虚拟机设置 -> 选项 -> 共享文件夹` 
上传本文件到虚拟机。

设置完毕后，命令行执行
 `vmware-hgfsclient && sudo vmhgfs-fuse .host:/ /mnt && sudo ls /mnt -o allow_other` 
即可查看共享文件

最后切换普通用户目录，执行 `bash /mnt/path/to/system-init/init-script.sh` 以完成安装。

脚本将`/opt`目录作为工作目录。并在家目录下创建名为`workspace`指向`/opt/src`的软链接。

```shell
$:/opt$ tree
.
├── bin              # 自定义启动文件目录
├── src              # 工作空间，存放项目源码
├── Language         # 开发语言安装目录
└── Tool             # IDE安装目录
```



脚本执行结束后，请重启，以使`bin`目录配置生效。

用到哪里补充到哪里。目前围绕`python` & `golang`展开。

持续更新中...