#!/bin/bash
echo "======================================"
echo "======================================" 
echo "========自动创建Rclone挂载服务========" 
echo "======================================" 
echo "======================================" 
RED='\E[1;31m'
END='\E[0m'
list=()
i=1
for item in $(sed -n "/\[.*\]/p" ~/.config/rclone/rclone.conf | grep -Eo "[0-9A-Za-z-]+")
do
	list[i]=${item}
	i=$((i+1))
done
for((j=1;j<=${#list[@]};j++))
do
	echo -e "${RED}${j}：【${list[j]}】${END}"

done



while [[ 0 ]]
do
	while [[ 0 ]]
	do
		echo
		read -n3 -p "请选择需要挂载的网盘（输入数字即可）：" rclone_config_name
		if [[ ${rclone_config_name}<=${#list[@]} && -n "${rclone_config_name}" ]];then
			echo -e "您选择了：${RED}${list[rclone_config_name]}${END}"
			break	
		fi
		echo
		echo "输入不正确，请重新输入。"
		echo
	done
	read -p "请输入需要挂载目录的路径（如不是绝对路径则挂载到/mnt下）:" path
	if [[ "${path:0:1}" != "/" ]];then
		path="/mnt/${path}"
	fi
	while [[ 0 ]]
	do
		echo -e "您选择了 ${RED}${list[rclone_config_name]}${END} 网盘，挂载路径为 ${RED}${path}${END}."
		read -n1 -p "确认无误[Y/n]:" result
		case ${result} in
			Y | y)
				echo
				break 2;;
			n | N)
				continue 2;;
			*)
				echo
				continue;;
		esac
	done
	
done



if [[ ! -d ${path} ]];then
	echo "${path} 不存在，正在创建..."
	mkdir -p ${path}
	echo "创建完成！"
fi




echo "正在检查服务是否存在..."
if [[ -f rclone-${list[rclone_config_name]}.service ]];then
        echo "found \"rclone-${list[rclone_config_name]}.service\",removed."
        rm ./rclone-${list[rclone_config_name]}.service
fi
echo "[Unit]
Description = rclone-sjhl

[Service]
User = root
ExecStart = /usr/bin/rclone mount ${list[rclone_config_name]}: ${path} --transfers 10  --buffer-size 1G --vfs-read-chunk-size 256M --vfs-read-chunk-size-limit 2G  --allow-non-empty --allow-other --dir-cache-time 12h --umask 000 
Restart = on-abort

[Install]
WantedBy = multi-user.target" > /lib/systemd/system/rclone-${list[rclone_config_name]}.service
echo "服务创建成功。"
echo “启动服务...”
systemctl start rclone-${list[rclone_config_name]}.service &> /dev/null
echo "添加开机启动..."
systemctl enable rclone-${list[rclone_config_name]}.service &> /dev/null
if [[ $? ]];then
	echo "finish."
fi

