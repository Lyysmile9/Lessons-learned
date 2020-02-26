#!/bin/bash

export PATH=/home/xm/AHD_BSP/main/poky/sources/linux-x86/toolchain/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH

dir=(/home/xm/zadas /home/xm/ZM_A7_AHD_GENERIC)

get_old_commit()
{
	git log --abbrev --oneline -1 > /home/xm/HEAD
	c=$(cat /home/xm/HEAD)
	OldCommit=$(echo ${c:0:6})
	echo "Old commot: $OldCommit"
}

get_new_commit()
{
	git log --abbrev --oneline -1 > /home/xm/gitpull
	c=$(cat /home/xm/gitpull)
	NewCommit=$(echo ${c:0:6})	 
	echo "New commit: $NewCommit"
}

get_backup_file_number()
{
	counterf=$(ls -l $CurrentDir/out/backup/ | grep "^d" | wc -l)
	echo "The number of files in the $CurrentDir/out/backup is: $counterf)"
}

clean_up_local_environment()
{
	git reset --hard $OldCommit
}

update_code()
{
	if [ $i -eq 0 ]; then
		branch=zm_develop_ahd_2.0_dev
	else
		branch=master
	fi
	
	git fetch origin $branch
	git reset --hard origin/$branch
}

remove_process_file()
{
	echo "remove process file"
	rm -rf /home/xm/HEAD /home/xm/gitpull
}

clean_out_old_files()
{
	if [[ "$counterf" -gt "1" ]]; then
		echo "do remove modify time greater than 7 days directory"
		find $CurrentDir/out/backup/ -mtime +7 -type d | xargs rm -rf
	fi

}

do_make()
{
for i in 0 1
do
	CurrentDir=${dir[i]}
	cd $CurrentDir
	echo "currentdir:"$CurrentDir

	get_old_commit
	clean_up_local_environment
	update_code
	get_new_commit
	get_backup_file_number	

	if [[ "$OldCommit" != "$NewCommit" ]] || [[ "$counterf" -eq 0 ]]; then
		make SKIP_CODING_STYLE_CHECK=1
		mv $CurrentDir/out/linux_atlas7 $CurrentDir/out/backup/linux_atlas7_$NewCommit
	elif [[ "$OldCommit" == "$NewCommit" ]]; then
		echo "Is up to date."
	fi

	remove_process_file
	clean_out_old_files
done
}
	
do_make

exit 0

