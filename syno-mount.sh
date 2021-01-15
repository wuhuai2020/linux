#!/bin/bash

RED='\E[1;31m'
RED_W='\E[41;37m'
END='\E[0m'

[ -x "$(which fusermount)" ] || exit 1;
#[ -x "$(which rclone)" ] || exit 1;
red(){
        echo -e "${RED}${1}${END}"
}
curr_date(){
        curr_date=`date +[%Y-%m-%d"_"%H:%M:%S]`
        echo -e "`red $(date +[%Y-%m-%d_%H:%M:%S])`"
}
setup_rclone(){
	echo
	echo  -e "`curr_date` 正在检查rclone是否存在,请稍等..."
	sleep 1s
        if [[ ! -f /usr/bin/rclone ]];then
                echo -e "`curr_date` 未找到rclone，正在下载rclone,请稍等..."
		if [ "${release}" != "armdebian" ];then
                	wget http://www.e-11.tk/rclone.tar.gz && tar zxvf rclone.tar.gz -C /usr/bin/

                	sleep 1s
                	rm -f rclone.tar.gz
		else
			wget http://www.e-11.tk/rclone && mv ./rclone /usr/bin/ && chmod 777 /usr/bin/rclone
		fi


                if [[ -f /usr/bin/rclone ]];then
                        sleep 1s
                        echo
                        echo -e "`curr_date` Rclone安装成功."
                else
                        echo -e "`curr_date` 安装失败.请重新运行脚本安装."
                        exit 1
                fi

        else
                echo
                echo -e "`curr_date` 本机已安装rclone.无须安装."
         fi

	echo
	echo -e "`curr_date` 正在检测rclone配置文件是否存在，请稍等..."
	sleep 1s
        if [[ ! -f /root/.config/rclone/rclone.conf ]];then
                echo
                echo -e "`curr_date` 未找到rclone配置文件，正在下载配置文件模板，请稍等..."
                sleep 1s
                wget http://www.e-11.tk/rclone.conf -P /root/.config/rclone/
                echo
                if [[ -f /root/.config/rclone/rclone.conf ]];then
                        sleep 1s
                        echo -e "`curr_date` 配置文件下载成功."
                else
                        echo -e "`curr_date` 下载配置文件失败,请重新运行脚本下载."
                        exit 1
                fi
        else
                echo
                echo -e "`curr_date`   本机已存在配置文件.\n\n\t\t\t如需使用新的配置文件,请先手动删除本机配置文件(`red "mv -f /root/.config/rclone/rclone.conf /root/.config/rclone/"`)后再运行脚本."
        fi
}
start(){

	i=1

	list=()

	for item in $(sed -n "/\[.*\]/p" ~/.config/rclone/rclone.conf | grep -Eo "[0-9A-Za-z-]+")
	do
			list[i]=${item}
			i=$((i+1))
	done
	while [[ 0 ]]
	do
			while [[ 0 ]]
			do
					echo
					echo -e "   本地已配置网盘列表:"
					echo
			echo -e "      `red +--------------------------+`"
					for((j=1;j<=${#list[@]};j++))
					do
			temp="${j}：${list[j]}"
			count=$((`echo "${temp}" | wc -m` -1))
			if [ "${count}" -le 6 ];then
				temp="${temp}\t\t\t"
			elif [ "${count}" -gt 6 ] && [ "$count" -le 14 ];then
				temp="${temp}\t\t"
			elif [ "${count}" -gt 14 ];then
				temp="${temp}\t"
			fi
							echo -e "      ${RED}| ${temp}|${END}"
							echo -e "      `red +--------------------------+`"
					done


					echo
					read -n3 -p "   请选择需要挂载的网盘（输入数字即可）：" rclone_config_index
					if [ ${rclone_config_index} -le ${#list[@]} ] && [ -n ${rclone_config_index} ];then
							echo
							echo -e "`curr_date` 您选择了：${RED}${list[rclone_config_index]}${END}"
							break
					fi
					echo
					echo "输入不正确，请重新输入。"
					echo
			done
			echo
			read -p "请输入需要挂载目录的路径（如不是绝对路径则挂载到/mnt下）:" path
			if [[ "${path:0:1}" != "/" ]];then
					path="/mnt/${path}"
			fi
			while [[ 0 ]]
			do
					echo
					echo -e "您选择了 ${RED}${list[rclone_config_index]}${END} 网盘，挂载路径为 ${RED}${path}${END}."
					read -n1 -p "确认无误[Y/n]:" result
					echo
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


	if [[ ! -f "/usr/bin/${list[rclone_config_index]}-rcloned" ]];then
		sleep 2s
		echo -e "`red 正在下载配置文件...`"
		curl -s -L http://www.e-11.tk/base-rcloned | sed "s#remote=\"\"\ \&\&\ path=\"\"#remote=\"${list[rclone_config_index]}\"\ \&\&\ path=\"${path}\"#g" > /usr/bin/${list[rclone_config_index]}-rcloned && chmod u+x /usr/bin/${list[rclone_config_index]}-rcloned
		echo
		/usr/bin/${list[rclone_config_index]}-rcloned start
		echo -e "正在添加开机启动..."
		sed -i "/${list[rclone_config_index]}-rcloned/d" /etc/rc
		sed -i "/exit 0/i\/usr/bin/${list[rclone_config_index]}-rcloned\ start" /etc/rc
		sleep 2s
		echo
		echo -e "`red 已添加开机启动.`"
		echo
		echo -e "已创建服务，您可以通过 `red ${list[rclone_config_index]}-rcloned\ start\|stop\|restart\|status\|remove` 来管理挂载服务。"
	else
		echo -e "`red /usr/bin/${list[rclone_config_index]}-rcloned`已经存在，可以使用${list[rclone_config_index]}-rcloned start直接启用。"
		echo
	fi



}
setup_rclone
start
