#!/bin/bash
# reuse the source code contained in the file instrument_without_odile_on_listen_mode_and_start_app.sh
# In this file we redo instrumentation.


# the first argument is the apk path, 
#  the second is the external storage global workspace (to store datas-eg all generated files) 
# the third is the number of iteration when testing

	
#
# usage : reinstall_start_observe_baseline_memory.sh apk_path number_of_methods
# example in our case: 
# ./reinstall_start_and_observe_baseline_memory.sh /media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/frida_evaluation_on_many_apps/apks/locker-fe666e209e094968d3178ecf0cf817164c26d5501ed3cd9a80da786a4a3f3dc4.apk  /media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/frida_evaluation_on_many_apps 33
# 		
#

#
MISC=x86
echo "-----> setting the global workspace " 

#The project folder
GLOBAL_WORKSPACE="/home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project"

#the jar file of louison giztinger instrumenter.
INSTRUMENTER_JAR_FILE=$GLOBAL_WORKSPACE/instrumenter_related_tools/groom/static/build/libs/killerdroid-static-3.0.jar 
#the instrumenter config files (the real file we will consider is main.json_template)
INSTRUMENTER_CONFIG_FILE=$GLOBAL_WORKSPACE/instrumenter_related_tools/groom/static/main.json

#The gadget so files folder  (I reused the same as with odile,
#if it does not work I will used the old one present on Louison Instrumenter folder) 
GADGET_SO_FILES=$GLOBAL_WORKSPACE/frida_related_tools/gadget_so_files

number_of_iterations=$3
number_of_iterations=${number_of_iterations/.*}
echo "MISC = $MISC"

if [ -z "$1" ] 
   then
	echo "No apk path supplied as argument "; exit 1;
else
    echo "testing apk $1"     
	echo "Ensure you have already started the emulator!!!"
	#adb root
	
	
	echo "----- ----- ----- >>  Getting the name of the apk ";   
	pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	act=$(aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	echo "package name : $pkg"
	echo "start activity name : $act"
    echo "uninstalling the app before doing first mesurements"
    adb uninstall $pkg
	app_file_name_without_extension=$(basename -s .apk $1)
	echo "----- file name _wthout_extension : $app_file_name_without_extension"
    
	RESULT_FOLDER=$2/memory_observations/${app_file_name_without_extension}/baseline
    rm -rfv $RESULT_FOLDER
	mkdir -pv $RESULT_FOLDER
	echo "----- ----- ----- >> First mesurements before installation"

	i="0"
	while [ $i -lt 5 ]
	do
	    output_file_path=$RESULT_FOLDER/${i}_before_starting_app_$(date)  
		output_file_path=${output_file_path//[ ,:+()]/_} #removing spaces, "," and ":"
		adb shell "dumpsys meminfo ${pkg}" > $output_file_path
		i=$[$i+1]
		sleep 0.5
	done
   
    
	adb install $1 
    adb shell am start -n $pkg/$act

    echo "----- ----- ----- >> Second mesurement after installation"

   	
	while [ $i -lt $number_of_iterations ]
	do
		echo "--- i = $i"
	    output_file_path=$RESULT_FOLDER/${i}_after_sending_js_methods_code_$(date)  
		output_file_path=${output_file_path//[ ,:+()]/_} #removing spaces, "," and ":"
		adb shell "dumpsys -t 60 meminfo ${pkg}" > $output_file_path		
		i=$[$i+1]
		sleep 0.3
	done 
	adb uninstall $pkg
 fi 
echo "----- ----- ----- >> Test realised on $(date)"; 



