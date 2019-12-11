#!/bin/bash

export PATH=/home/xm/AHD_BSP/main/poky/sources/linux-x86/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH

dir=(/home/xm/zadas)

#	for i in 0 1
#	do
currentdir=${dir[i]}
cd $currentdir
echo "currentdir:"$currentdir
#git branch
git log --abbrev --oneline -1 > /home/xm/HEAD

cat /home/xm/HEAD | while read -r -a word;
	do
		echo "current commit: $word"
		git reset --hard $word
		git fetch origin zm_develop_ahd_2.0_dev
		git reset --hard origin/zm_develop_ahd_2.0_dev
		git log --abbrev --oneline -1 > /home/xm/gitpull
		cat /home/xm/gitpull |  while read -r -a words;
		do
			counterf=$(ls -l $currentdir/out/backup/ | grep "^d" | wc -l);
			echo $counterf

			if [[ "$word" != "$words" ]] || [[ "$counterf" -eq 0 ]]; then
#				git reset --hard $words
#				rm -rf /home/xm/AHD_ZADAS/out/linux_atlas7 
				make SKIP_CODING_STYLE_CHECK=1
				mv $currentdir/out/linux_atlas7 $currentdir/out/backup/linux_atlas7_$words
				elif [[ "$word" == "$words" ]]; then
				echo "Is up to date..."
			fi

		rm -rf /home/xm/HEAD /home/xm/gitpull

#git pull origin zm_ahd_2.0_dev

		if [[ "$counterf" -gt "1" ]]; then
			echo "do remove modify time greater than 7 days directory"
			find $currentdir/out/backup/ -mtime +7 -type d | xargs rm -rf
		fi

		done
	done
exit 0
