#! /bin/bash

##  TomThumb v0.1.0 Copyright 2019 Joe Koop; MIT licence

whoami=$(whoami)

mkdir -p /home/$whoami/.tomthumb
cd /home/$whoami/.tomthumb/

function sync(){
	if [ "$1" == '' ]; then
		echo "["$(date +%H:%M:%S)"] [Fatal] \$1 not set; Set \$1 to root directory of external drive"
		echo "["$(date +%H:%M:%S)"] [Info ] Sync exit status 1"
		return 1
	fi

	input="$1/"
	echo "["$(date +%H:%M:%S)"] [Info ] Using external directory \"$input\""
	echo "["$(date +%H:%M:%S)"] [Info ] Getting UUID of \"$input\""
	uuid=$(sudo blkid $(df --output=source "$input" | tail -n 1) -po export | grep ^UUID= | sed 's/UUID=//g')
	date=$(date +%Y-%m-%d_%H-%M-%S)
	local="UUID=/$uuid/$date"
	echo "["$(date +%H:%M:%S)"] [Info ] Using internal directory \"$local/\""
	echo "["$(date +%H:%M:%S)"] [Info ] Preparing for copy..."

	if [ -d UUID=/$uuid ]; then
		sudo cp -rl UUID=/$uuid/$(ls -1 UUID=/$uuid | tail -n 1) $local
		err=$?

		if [ '0' != "$err" ]; then
			echo "["$(date +%H:%M:%S)"] [Fatal] Preparation error"
			echo "["$(date +%H:%M:%S)"] [Info ] Sync exit status 5"
			return 5
		fi
	fi

	echo "["$(date +%H:%M:%S)"] [Info ] Preparation success"
	mkdir -p $local
	err=$?

	if [ '0' != "$err" ]; then
		echo "["$(date +%H:%M:%S)"] [Fatal] Permissions error"
		echo "["$(date +%H:%M:%S)"] [Info ] Sync exit status 2"
		return 2
	fi

	echo -e "["$(date +%H:%M:%S)"] [Info ] Rsync...\n"
	sudo rsync -avE --del "$input" $local
	err=$?

	if [ '0' != "$err" ]; then
		echo -e "\n["$(date +%H:%M:%S)"] [Fatal] Rsync error"
		sudo mv $local $local\_err
		echo "["$(date +%H:%M:%S)"] [Info ] Sync exit status 3"
		return 3
	fi

	echo -e "\n["$(date +%H:%M:%S)"] [Info ] Rsync success; You may now unmount the external drive"
}

function compress(){
	echo "["$(date +%H:%M:%S)"] [Info ] JDupes..."
	jdupes -rLHzpq .
	err=$?

	if [ '0' != "$err" ]; then
		echo "["$(date +%H:%M:%S)"] [Fatal] JDupes error"
		echo "["$(date +%H:%M:%S)"] [Info ] Sync exit status 4"
		return 4
	fi

	echo "["$(date +%H:%M:%S)"] [Info ] JDupes success"
	echo "["$(date +%H:%M:%S)"] [Info ] Local drive occupied: "$(du -sh . | sed 's/\t.//g')
}

old=""
new=$(ls -1 /media/$whoami)

if [ "$1" != '' ]; then
	diff=$1

	until [ $(echo "$diff" | sed -r '/^\s*$/d' | wc -l) -lt '1' ]
	do
		sync "/media/$whoami/"$(echo "$diff" | head -n 1)
		diff=$(echo $diff | tail -n $(expr $(echo "$diff" | wc -l) - 1))
	done

	compress
	sleep 2
	exit
fi

while :
do
	old=$new
	new=$(ls -1 /media/$whoami)
	diff=$(diff -u <(echo "$old") <(echo "$new") | grep -E "^\+" | sed 's/^+//g')
	diff=$(echo "$diff" | tail -n $(expr $(echo "$diff" | wc -l) - 1))

	if [ "$diff" != '' ]; then
		gnome-terminal -- "$0" "$diff"
	fi

	sleep 1
done
