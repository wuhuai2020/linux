# 一键安装Emby、rclone、自动挂载rclone脚本
    linux一键安装rclone、emby、配置rclone挂载服务
    
##  安装方法：
    bash <(curl -s -L https://git.io/11plus.sh)

  如有问题请联系 [电报群](https://t.me/P11DrivePlus "电报群地址")
# 脚本功能介绍

## 1、安装rclone

      目前是检测系统是否安装rclone，如果没安装就安装世纪互联版的rclone和配置文件。  
  
## 2、安装/更新Emby

      检测系统是否安装emby，未安装就安装最新版本的emby，如果已经安装就检测是否最新，如果不是最新就更新emby到最新。  
  
## 3、安装rclone服务

      读取rclone配置文件中的网盘，根据需求选择网盘挂载并设置为服务，同时设置开机自动挂载。做到不用输入冗长的命令，直接使用systemctl来管理挂载。  
  
## 4、复制emby削刮包

      11plus特色功能，离线削刮包，要求挂载11plus网盘 并必须挂载到/mnt/video这个文件夹下。  
      
  ## 5、SWAP配置

      添加/删除交换分区，解决物理内存不够的问题。  
  
