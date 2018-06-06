#!/data/data/com.termux/files/usr/bin/bash

me="\e[38;5;196m"
hi="\e[38;5;82m"
ku="\e[38;5;226m"
bi="\e[38;5;21m"
cya="\e[38;5;13m"
co="\e[38;5;202m"
mag="\e[38;5;14m"
bpu="\e[48;5;231m"
tbl="\e[1m"
dim="\e[2m"
no="\e[0m"
bnr() {
clm=$(tput cols)
banner1="* M.A.R.T - Mobile Android ROM Translator *"
banner2="* by gk-dev *"
b1="$(printf "%*s\n" $(((${#banner1}+$clm)/2)) "$banner1")"
b2="$(printf "%*s\n" $(((${#banner2}+$clm)/2)) "$banner2")"
brs
echo -e "$bpu$tbl$co$b1$(printf "%*s\n" $(($clm-${#b1})))"
echo -e "$b2$(printf "%*s\n" $(($clm-${#b2})))$no"
brs
echo ""
}
brs() {
devider="$(printf '%*s' $clm | tr " " "=")"
echo -e "$tbl$mag$devider$no"
}

first_install() {
	bnr;
	p "${ku}$l_repo_pointless_install"
	echo -e "$mag"
	mkdir $PREFIX/etc/apt/sources.list.d
	echo "deb [trusted=yes] https://its-pointless.github.io/files/ termux extras" > $PREFIX/etc/apt/sources.list.d/pointless.list
	wget https://its-pointless.github.io/pointless.gpg
	apt-key add pointless.gpg
	apt update
	rm pointless.gpg
	echo -e "\n${hi}$l_notif_done"
	sleep 2
	bnr;
	p "${ku}$l_depinstall"
	echo -e "$mag"
	yes | pkg up
	yes | pkg install python readline coreutils unzip tar file figlet curl wget gnup* grep ncurs* p7zip zip unzip pv proot util-linux sed awk
	echo -e "\n${hi}$l_notif_done"
	sleep 2
	bnr;
	p "\n${ku}l_create_mart_shortcut${no}\n"
	ln -s $root/gk.sh $PREFIX/bin/gkmart
	sleep 2
	p "\n${hi}$l_notif_done\n${no}\n${mag}$l_create_mart_shortcut_done${no}"
	sleep 5
}
choose_language() {
	current_lang="$(cat $mart_set | grep "settings_language" | cut -d"=" -f2)"
	export crlng=$current_lang
	source $tools/lang/$current_lang
}
quit() {
	bnr;
	p "$l_exit_massage"
	figlet gk-dev
	echo -e "$no"
	exit
}

settings_menu() {
	repo_lang="$(cat $mart_set | grep "settings_repo_language" | cut -d"=" -f 2)"
	apktool_v="$(cat $mart_set | grep "settings_apktool" | cut -d"=" -f 2)"
	aapt_v="$(cat $mart_set | grep "settings_aapt" | cut -d"=" -f 2)"
	smali_v="$(cat $mart_set | grep "settings_smali" | cut -d"=" -f 2)"
	baksmali_v="$(cat $mart_set | grep "settings_baksmali" | cut -d"=" -f 2)"
	bnr;
	ech="${tbl}${ku}$l_title_settings_menu${no}

$l_title_settings_summary_repo
 1. $l_title_settings_available_repositories
 2. $l_title_settings_lang_translate @: $cya$repo_lang$no

$l_title_settings_summary_apktool
 3. $l_title_settings_apktool_version @: $cya$apktool_v$no
 4. $l_title_settings_aapt @: $cya$aapt_v$no
 5. $l_title_settings_smali @: $cya$smali_v$no
 6. $l_title_settings_baksmali @: $cya$baksmali_v$no

$l_title_settings_summary_mart
 7. $l_title_settings_auto_update
 8. $l_title_settings_check_update
 9. $l_title_settings_mart_language
 
 0. $ku$l_back_main$no"
	echo -e "$ech" | awk -F"@" 'NR==1,NR==18{ printf "%-25s %s\n", $1,$2} '
	brs;
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) #Choosing default
				main_menu; break;;
			2) main_menu; break;;
			3) main_menu; break;;
			4) main_menu; break;;
			5) main_menu; break;;
			6) main_menu; break;;
			7) main_menu; break;;
			8) main_menu; break;;
			9) #language settings
				while :; do
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_summary_list_available_language${no}\n"
				names=""
				names=( $(ls $tools/lang | cut -d"-" -f1) )
				dym opt in ${names[@]}
				if [ "$opt" != "" ]; then
					echo -e "${tbl}${cya}$opt${no} $l_title_settings_choosen_mart_lang"
					sed -i "s/$crlng/${opt}-lng/g" $mart_set
					echo -e "\n$l_notif_restart_choosen_lang\n"
						for i in {5..0}; do 
							printf "\r$l_notif_countdown_restart" $i
							sleep 1
						done
					reset 2&1>/dev/null
					./mart.sh
				fi
				done; break;;
			0) main_menu; break;;
			y) isntall_update; break;;
			*) echo -e "${me}$l_title_main_menu_wrong_options${no}";;
		esac
	done
}

menu_new_project() {
	while :; do
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	romname=""
	romname1=""
	bnr
	echo -e "${ku}$l_create_new_project$no\n"
	read -p "" romname1
	export romname=$(echo "$romname1" | sed 's/ /_/g' | sed 's/@/_/g')
	if [[ -z "$romname" ]]; then
		bnr;
		echo -e "$l_notif_error \n"
		echo -e "$l_create_new_project_empty_input"
		sleep 2
		continue
	fi
		if [[ ! $(ls -d $target/*/ 2>/dev/null | grep "mart_$romname/") ]]; then
			mkdir -p $target/mart_$romname/.logs
			if [[ -z "$currentpr" ]]; then
				sed -i "s/settings_current_project=/settings_current_project=mart_$romname/g" $mart_set
				else
				sed -i "s/$currentpr/mart_$romname/g" $mart_set
			fi
			main_menu;
		else
			bnr;
			echo -e "$l_notif_error \n"
			echo -e "$l_create_new_project_already"
			sleep 2
			romname=""
			continue
		fi
	done
}

menu_continue_project() {
	while :;do
	bnr;
	echo -e "${tbl}${ku}$l_continue_project_summary$no\n"
	names=( $(ls -d $target/* | grep "mart_" | rev | cut -d"/" -f1 | rev) )
			dym opt in ${names[@]}
			if [ "$opt" != "" ]; then
				echo -e "\n${cya}$opt${no} $l_continue_project_choosen"
				sed -i "s/$currentpr/$opt/g" $mart_set
				sleep 2
				main_menu;
			break
			fi
		done
}
menu_delete_project() {
	while :; do
	countp=""
	countp=$(ls -d $target/* 2>/dev/null | grep "mart_" | wc -l)
		if [ "$countp" = "0" ]; then
			menu_new_project;
		fi
	bnr;
	echo -e "${tbl}${ku}$l_delete_project_summary${no}\n"
	names=( $(ls -d $target/* 2>/dev/null | grep "mart_" | rev | cut -d"/" -f1 | rev) )
	currentpr=""
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	dym opt in ${names[@]}
        	if [ "$opt" != "" ]; then
        		if [ "$opt" = "$currentpr" ]; then
        			rm -R $target/$opt
        			changepr=( $(ls -d $target/* 2>/dev/null | grep "mart_" | rev | cut -d"/" -f1 | rev | head -1) )
        			sed -i "s/$currentpr/$changepr/g" $mart_set
        		else
        			rm -R $target/$opt
        		fi
        			echo -e "\n${cya}$opt${no} $l_delete_project_choosen"
        			sleep 2
        		continue
        	fi
        done
}
menu_rom_extract() {
	currentpr=""
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	workdir="$target/$currentpr"
	bnr
	echo -e "${ku}$l_extract_menu_summary$no

 1. $l_extract_menu_from_zip
 2. $l_extract_menu_from_system

 0. ${ku}$l_back$no

 $l_insert_options
 "
	while read env; do
		case $env in
			1) #start extracting zip from workdir
				while :; do
				bnr;
				findzip=""
				findzip="$(ls $workdir | grep ".zip")"
				zipfile="$(basename $findzip)"
				if [ -z $findzip ]; then
					echo -e "$l_notif_error\n"
					echo -e "$l_extract_missing_zip ${co}$currentpr$no\n"
					echo -e "$l_extract_reinsert_zip ${co}$currentpr$no"
					sleep 5
					menu_rom_extract
				else
					echo "mart_in_zipname=$zipfile" >> $workdir/project_info.txt
					echo -e "$l_extract_notif ${co}$zipfile...$no\n"
					mkdir $workdir/exrom
					7z x $workdir/$zipfile -o$workdir/exrom
					typeimg="$(ls $workdir/exrom/ | grep "system.new.dat")"
					if [ -f "$workdir/exrom/$typeimg" ]; then
						export d2m=$tools/imgtools/sdat2img.py
						mkdir $workdir/.tmp
						bnr;
						echo -e "$l_extract_unpack_notif ${co}$typeimg$no\n"
						$d2m $workdir/exrom/system.transfer.list $workdir/exrom/system.new.dat $workdir/.tmp/raw.img
						imgsize="$(wc -c $workdir/.tmp/raw.img | cut -d" " -f1)"
						echo "mart_getimgsize=$imgsize" >> $workdir/project_info.txt
					fi
					main_menu 
				fi
				done ; break;;
			2) #must be on root mode to use this feature
				echo "null"
				sleep 3 ; main_menu ; break;;
			0) main_menu ; break;;
			*) echo "masukan salah"
		esac
	done
}

dym() {
	local v e
	declare -i i=1
	v=$1
	shift 2
	for e in "$@" ; do
		echo " ${i}. $e"
		i=i+1
	done
	echo -e "\n${tbl}${ku} m. $l_back_main$no"
	echo -e "\n$l_insert_options"
	read -i "" REPLY
	if [ "$REPLY" = "m" ]; then
		main_menu;
	fi
	i="$REPLY"
		if [[ $i -gt 0 && $i -le $# ]]; then
		export $v="${!i}"
		else
		echo -e "$l_wrong_input"
		export $v=""
		sleep 2
		fi
}

about_mart() {
	bnr;
	about="$mag$(cat $setfd/about)$no"
	p "$about"
	echo ""
	read -s -n 1
	main_menu;
}

main_menu() {
	bnr
	countp=""
	countp=$(ls -d $target/* 2>/dev/null | grep "mart_" | wc -l)
	if [[ "$countp" = "0" ]]; then
		menu_new_project;
		fi
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	mmenu="
${tbl}${ku}$l_title_main_menu_info${no}

$l_title_main_menu_current_project @: ${cya}$currentpr$no
$l_title_main_menu_mart_version @: ${mag}$mart_version$no

${tbl}${ku}$l_title_main_menu${no}

  1. $l_title_main_menu_new_project
  2. $l_title_main_menu_continue_project
  3. $l_title_main_menu_delete_project
  4. $l_title_main_menu_rom_extract
  5. $l_title_main_menu_build
  6. $l_title_main_menu_settings
  7. $l_title_main_menu_about
  
  0. ${me}$l_exit$no
"
	echo -e "$mmenu" | awk -F"@" 'NR==2,NR==20{ printf "%-15s %s\n", $1,$2} '
	brs
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) menu_new_project; break;;
			2) menu_continue_project; break;;
			3) menu_delete_project; break;;
			4) menu_rom_extract; break;;
			5) menu_build; break;;
			6) settings_menu; break;;
			7) about_mart; break;;
			0) quit; break;;
			*) echo -e "$l_wrong_input";;
		esac
	done
}
gkhome=$(pwd)
export root=$gkhome
cd $root
export tools=$root/tools
export mkfs=$tools/img/toolsmake_ext4fs
target=~/storage/shared/M.A.R.T
projectdir="$target/project"
logsdir="$target/logs"
mart_set="$tools/settings/settings"
setfd="$tools/settings"
mart_version=$(grep "MART V" README.md | cut -d" " -f3)
source $tools/settings/demo -w0.1
DEMO_PROMPT=""
curret_version=$(grep "# MART V" README.md | cut -d" " -f3)
choose_language;
main_menu;
