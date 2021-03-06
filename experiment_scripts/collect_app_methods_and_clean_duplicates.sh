#!/bin/bash
# we reuse the source code contained in the file instrument_without_odile_on_listen_mode_and_start_app.sh
# In this file we don't redo instrumentation. Make sure you have already instrumented the 
# app using instrument_without_odile_on_listen_mode_and_start_app
# so that the file INSTRUMENTER_OUTPUT_FOLDER=$TMP_FOLDER/instrumented_apks_of_$pkg  of the same apk is present
#
# The first argument is the apk path,  the second (ie NNN) is the tracing duration in seconds, 
# The third is the external storage global workspace (to store datas-eg all generated files)
# Using  tracer.py, it will produce a file
#  in the folder methods_loaded_by_apps named  app_name.json
# where app_name is the app name without extension (.apk).
#
# Just for explanations the first script (tracer.py) will collect methods with duplicates from the started app
# The result will be added  in the file
#  methods_loaded_by_apps/app_name.json
# Then we will add another file
# methods_loaded_by_apps/app_name.json
# after removing duplicates from the previous one
# usage : collect_app_methods_and_clean_duplicates.sh apk_path NNN
# example in our case: ./collect_app_methods_and_clean_duplicates.sh 
#  		android_frida_tools/apks/locker-fe666e209e094968d3178ecf0cf817164c26d5501ed3cd9a80da786a4a3f3dc4.apk 
#			NNN
#             /media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/frida_evaluation_on_many_apps
# 		
#
#
MISC=x86
echo "-----> setting the global workspace " 

#Maximum json file size in Bytes
MAX_JSON_FILE_SIZE=5000000 #1MB


#The project folder
GLOBAL_WORKSPACE="/home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project"

#the jar file of louison giztinger instrumenter.
INSTRUMENTER_JAR_FILE=$GLOBAL_WORKSPACE/instrumenter_related_tools/groom/static/build/libs/killerdroid-static-3.0.jar 
#the instrumenter config files (the real file we will consider is main.json_template)
INSTRUMENTER_CONFIG_FILE=$GLOBAL_WORKSPACE/instrumenter_related_tools/groom/static/main.json

#The gadget so files folder  (I reused the same as with odile,
#if it does not work I will used the old one present on Louison Instrumenter folder) 
GADGET_SO_FILES=$GLOBAL_WORKSPACE/frida_related_tools/gadget_so_files

#All temporary files generated by this script
app_file_name_without_extension=$(basename -s .apk $1)
TMP_FOLDER=$3/instrumentation_tmp_folder/${app_file_name_without_extension}

JSON_FOLDER=$3/methods_loaded_by_apps






echo "MISC = $MISC"

if [ -z "$1" ] 
   then
	echo "No apk path supplied as argument "; exit 1;
else
    echo "testing apk $1"

	echo "Ensure you have already started the emulator and started the instrumentation app!!!"
	#adb root
<< 'MULTILINE-COMMENT'  
	# we don't need to reinstall app anymore
	echo "----- ----- ----- >>  Getting the name of the apk ";   
	pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	act=$(aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	echo "package name : $pkg"
	echo "start activity name : $act"
    echo "uninstalling the app before doing first mesurements"
    adb uninstall $pkg
    
	

   
	
	echo "----- ----- ----- >> First mesurements before installation"



    # WARNING: make sure this file is present
	INSTRUMENTER_OUTPUT_FOLDER=$TMP_FOLDER/instrumented_apks_of_$pkg
	repackagedApk="$(ls $INSTRUMENTER_OUTPUT_FOLDER)"
	adb install $INSTRUMENTER_OUTPUT_FOLDER/$repackagedApk 
    adb shell am start -n $pkg/$act

    echo "----- ----- ----- >> Waiting few seconds after installation"
	sleep 5

MULTILINE-COMMENT

	time_passed="0"
    echo " ----- ----- ----- >> Sending requests to the tracer"
	json_output_file_path=$JSON_FOLDER/${app_file_name_without_extension}.json
	rm $json_output_file_path
	
	pid_file=$JSON_FOLDER/tracer.pid
	
	( cd android_frida_tools && ./tracer.py -o $json_output_file_path > $JSON_FOLDER/tracer_${app_file_name_without_extension}.json ) &  
	pid=$(echo $!)
	echo " ----- ----- ----- >> Old tracer pid = $pid"
	
	pid=$[$pid+2]
	echo $pid > $pid_file
	echo "----- ----- ----- >> command: ./tracer.py -o $json_output_file_path > $JSON_FOLDER/tracer_${app_file_name_without_extension}.json"
    echo " ----- ----- ----- >> New tracer pid = $pid"
	

	echo "----- ----- ----- >> Waiting few seconds after sending tracer script"
	sleep 5
	echo "----- ----- ----- >> json output file = $json_output_file_path"
    #gedit $json_output_file_path  &
 
    echo "----- ----- ----- >> Observing the json file"

   	old_file_size="0"
	max_time=$2
	comparison=$(echo "$time_passed < $max_time" | bc)
	while [ $comparison != 0 ]
	do
	    
		#looking is the json file size is enougth to 
        new_file_size=$(stat -c%s "$json_output_file_path"); 
		echo " --- --- >>  MAX_JSON_FILE_SIZE = $MAX_JSON_FILE_SIZE, new_file_size = $new_file_size"
		#Testing if the json file is big
		if [ $new_file_size -ge $MAX_JSON_FILE_SIZE ] 
		then
			echo " --- --- >> the json output is too big MAX_JSON_FILE_SIZE = $MAX_JSON_FILE_SIZE, new_file_size = $new_file_size"
			break
		fi 

		#Testing if the json file is stable
        if [ "$new_file_size" -eq "$old_file_size" ] && [ "$new_file_size" -ne "0" ]
		then
			echo " --- --- >> the tracer maybe has finished ! old_file_size = $old_file_size, new_file_size = $new_file_size"
			old_file_size=$new_file_size
			sleep 2
			new_file_size=$(stat -c%s "$json_output_file_path")
			if [ "$new_file_size" -eq "$old_file_size" ] && [ "$new_file_size" -ne "0" ]
		    then
				echo " --- --- >> the tracer has definetly finished ! old_file_size = $old_file_size, new_file_size = $new_file_size"
				break
		    fi 
	    fi 


		echo " --- --- >> we continue mesurements... new_file_size = $new_file_size ."
		comparison=$(echo "$time_passed < $max_time" | bc)
		echo " --- --- >> updtating time passed... time_passed = '$time_passed', max_time = $max_time, next comparison result: $comparison"
		old_file_size=$new_file_size
		
		

		
		sleep 0.5
		(echo "scale=4;$time_passed+0.5" | bc) > todel_
		time_passed=$(cat  todel_)
		rm todel_
	done

   
	echo "----- ----- ----- >> killing the tracer.py process"
	
	sleep 10
	kill -9 $(cat ${pid_file})

	echo "----- ----- ----- >> uninstalling the app"
	pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	echo "package name : $pkg"
	adb uninstall $pkg

	new_file_size=$(stat -c%s "$json_output_file_path")
	echo " --- --- >> new_file_size when finishing process = $new_file_size ."
	

	echo "----- ----- ----- >> removing duplicates"
	
	(tail -1 $json_output_file_path) > todel_
	last_line=$(cat  todel_)
	rm todel_

	if  [ "$last_line" != "]" ]
	then
		echo "]" >> $json_output_file_path # because it has been closed abruptly
		echo "----- ----- ----- >> adding the missing ending ] symbol to the file"
	fi 
	
	
	( cd android_frida_tools && ./expes_result_overview_tool.py -d -f $json_output_file_path )  


	rm $JSON_FOLDER/tracer_${app_file_name_without_extension}.json $pid_file
	
 fi 
echo "----- ----- ----- >> Test realised on $(date)"; 

