#!/bin/bash
# This script loops frida experiments on many apks contained in a folder 
# Parameters :
#	$1- the folder containing apks
#  	$2- the maximum time (in second) used to collect loaded methods on each app
#   $3- the gap which is the difference between the number of methods tested when benchmarking an app
#   $4- the Maximum of methods tested at each app
#   $5- the external memory folder to store results

# NB make sure you are in the good python env
# command example :
<< COMMAND  
source /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/venv/python3.5_scalability_experiments/bin/activate 
./repeat_experiments_on_apks.sh \
/media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/odile_scalability_evaluation_on_many_apps/apks  \
15 100 15000 \
/media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/odile_scalability_evaluation_on_many_apps  \
COMMAND
echo "--->> A- Retriving parameters"
apks_folder=$1
maximum_method_collection_time_per_app=$2
gap_when_benchmarking=$3
maximum_methods_tested_on_each_app=$4
external_storage_folder=$5

EXPERIMENTS_GLOBAL_WORKSPACE=/home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project
tracer_compilation_folder=$EXPERIMENTS_GLOBAL_WORKSPACE/frida_related_tools/tracers/art-tracer-emulator   

tracer_script_folder=$tracer_compilation_folder/agent
tracer_index_template_for_scalability_experiments=$tracer_script_folder/index_template_for_scalability_experiments





apk_counter=0
echo "--->> B-  Looping on apks folder "
<< EMULATOR_COMMENT
echo "--->> STOPPING EMULATOR"
bash stop_emulator.sh
sleep 5
echo "--->>  EMULATOR STOPPED"
EMULATOR_COMMENT

for apk_file in ${apks_folder}/*; do
    echo "--->> Processing application  file $apk_file"

<< EMULATOR-COMMENT	
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
EMULATOR-COMMENT
	echo "--->> 1 (start)- First instrumentation to collect method loaded by the app "
	#./instrument_on_listen_mode_and_start_app.sh $apk_file $external_storage_folder
	echo "--->> 1 (end)-  First instrumentation to collect method loaded by the app "
	#sleep 5
	echo "--->> 2- (start) Collecting app methods and clean duplicates"
	#./collect_app_methods_and_clean_duplicates.sh $apk_file $maximum_method_collection_time_per_app $external_storage_folder
	echo "--->> 2- (end) Collecting app methods and clean duplicates"
	#sleep 5
	echo "--->> 3- (start) Randomizing and split methods json file"
	#./randomize_and_split_methods_file_for_app.sh $apk_file $gap_when_benchmarking $external_storage_folder
	echo "--->> 3- (end) Randomizing and split methods json file"
	#sleep 5
	echo "--->> 4- (start) Benchmarking the apk:"
	echo "--->> testing the memory crash with Odile from $gap_when_benchmarking to $maximum_methods_tested_on_each_app methods, step : $gap_when_benchmarking "
	app_file_name_without_extension=$(basename -s .apk $apk_file)
	json_methods_file=${external_storage_folder}/methods_loaded_by_apps/${app_file_name_without_extension}.json
	number_of_methods=$(wc -l < $json_methods_file)
	number_of_methods=$(($number_of_methods - 2)) #for Brakets
	echo "--- *** *** >> total number of methods: $number_of_methods "
	
	app_experiment_result_folder=${external_storage_folder}/memory_observations/${app_file_name_without_extension}
	#rm -rf $app_experiment_result_folder
	#mkdir $app_experiment_result_folder
	i=$gap_when_benchmarking
	#if [ "$app_file_name_without_extension" == "locker-fe666e209e094968d3178ecf0cf817164c26d5501ed3cd9a80da786a4a3f3dc4" ]; then
	#	i=2000
	#fi
	rm -rf  $app_experiment_result_folder/*/*.pdf 
	rm -rf  $app_experiment_result_folder/*/*.data 
	rm -rf  $app_experiment_result_folder/*.pdf 

	
	while [ $i -lt $number_of_methods ] 
	do
		##### ##### #####  for scalability  experiments
		json_method_file_for_current_number_of_methods=${external_storage_folder}/methods_loaded_by_apps/input_files_for_experiments_for_$app_file_name_without_extension/${i}_entries.json
		echo "--->> Generating the correct tracer script for $number_of_methods methods "
		echo "--->> Command: ./tracer.py -O -p $tracer_index_template_for_scalability_experiments -f $json_method_file_for_current_number_of_methods -r $tracer_script_folder"
		#( cd android_frida_tools && ./tracer.py -O -p $tracer_index_template_for_scalability_experiments -f $json_method_file_for_current_number_of_methods -r $tracer_script_folder ) 
		#-O for Odile usage, the tracer.py will just generate the tracing script 
		#-p the tracer template (p for patron) file to modify
		#-f the method json file 
		#-r the folder where to put the index.ts result file

		echo "--->> Compiling the tracer"
        #(cd $tracer_compilation_folder  && npm run build)

<< EMULATOR-COMMENT
		echo "--->> STOPPING EMULATOR"
		bash stop_emulator.sh
		sleep 5
		echo "--->>  EMULATOR STOPPED"

	
		echo "--->> STARTING EMULATOR"
		if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
			echo "Emulator started"
		fi
		echo "--->>  EMULATOR STARTED"
EMULATOR-COMMENT

		##### ##### #####  for scalability  experiments
		echo " ----- ----- ----- >> testing  $i methods  for app $apk_file << ----- ----- ----- "
		echo "----- ----- ----- >> command: ./reinstall_start_and_observe_memory.sh $apk_file $i $external_storage_folder"
		#./instrument_reinstall_start_and_observe_memory.sh $apk_file $i $external_storage_folder
		#sleep 3

		echo " ----- ----- ----- >> generating partial plots  $i methods << ----- ----- ----- "
		echo "----- ----- ----- >> command: ./expes_result_overview_tool.py -x $app_experiment_result_folder -n $i"
		#( cd android_frida_tools && ./expes_result_overview_tool.py -x $app_experiment_result_folder -n $i -O ) 
		#evince "${app_experiment_result_folder}/${i}_methods_tested/plot_v2.pdf" &
		echo " ----- ----- ----- >> generating distinct methods detections  $i methods << ----- ----- ----- "    #modif, ajout du bloc
		json_input_file=${external_storage_folder}/methods_loaded_by_apps/input_files_for_experiments_for_${app_file_name_without_extension}/${i}_entries.json
		echo "----- ----- ----- >> command: ./expes_result_overview_tool.py -D -x $app_experiment_result_folder -f $json_input_file -n $i -O"
		#( cd android_frida_tools && ./expes_result_overview_tool.py -D -x $app_experiment_result_folder -f $json_input_file -n $i -O) #besoin de i???
		i=$[$i+$gap_when_benchmarking]
		#sleep 0.5
		if [ $i -gt $maximum_methods_tested_on_each_app ]
		then
			i=$[$i-$gap_when_benchmarking]
			break
		fi 
	done

	echo " ----- ----- ----- >> command ./expes_result_overview_tool.py -x $app_experiment_result_folder -m $i -g $gap_when_benchmarking "
	#( cd android_frida_tools && ./expes_result_overview_tool.py -x $app_experiment_result_folder -m $i -g $gap_when_benchmarking) 
	#evince "${app_experiment_result_folder}/*.pdf" &


	apk_counter=$[$apk_counter+1]
<<EMULATOR-COMMENT
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
EMULATOR-COMMENT
done
echo "--->> 4- (end) Benchmarking the apk:"





echo   "--->> C- generating  final plots  using the dataset generated foreach app "
memory_observation_folder=${external_storage_folder}/memory_observations
echo " ----- ----- ----- >> command ./expes_result_overview_tool.py -u -x $memory_observation_folder -g $gap_when_benchmarking -O"
#( cd android_frida_tools && ./expes_result_overview_tool.py -u -x $memory_observation_folder -g $gap_when_benchmarking -O) 
echo "--->>  TEST FINISHED SUCCESSFULLY !!! "

