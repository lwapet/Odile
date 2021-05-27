#!/bin/bash
# This script loops frida experiments on many apks contained in a folder 
# Parameters :
#	$1- the folder containing apks
#   $2- the external memory folder to store results
#   $3- number of iteration when collecting data

# NB make sure you are in the good python env
# command example :
 <<  COMMAND  
	source /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/venv/python3.5_scalability_experiments/bin/activate 
	./repeat_experiments_on_apks.sh \
	/media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/odile_scalability_evaluation_on_many_apps/apks  \
	/media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/odile_scalability_evaluation_on_many_apps  \
 
COMMAND

echo "--->> A- Retriving parameters"
apks_folder=$1
external_storage_folder=$2
number_of_iterations=$3

EXPERIMENTS_GLOBAL_WORKSPACE=/home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project
tracer_compilation_folder=$EXPERIMENTS_GLOBAL_WORKSPACE/frida_related_tools/tracers/art-tracer-emulator   
 # change the line above  for phone, make sure you saved the old index.ts 
 # and prepared the index template for new method you will have to test for scalability 
 # also prepare template for performance experiments
 # also modify the tracer_tracer_file_name
tracer_script_folder=$tracer_compilation_folder/agent
tracer_index_template_for_scalability_experiments=$tracer_script_folder/index_template_for_scalability_experiments
tracer_index_template_for_performance_experiments=$tracer_script_folder/index_template_for_performance_experiments
tracer_tracer_template_for_performance_experiments_short_path=$tracer_script_folder/tracer_x86_short_path_template
tracer_tracer_template_for_performance_experiments_long_path=$tracer_script_folder/tracer_x86_long_path_template
tracer_tracer_file_name=$tracer_script_folder/tracer_x86.ts


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


	
	app_file_name_without_extension=$(basename -s .apk $apk_file)
	app_memory_experiment_result_folder=${external_storage_folder}/memory_observations/${app_file_name_without_extension}
	app_cpu_experiment_result_folder=${external_storage_folder}/cpu_observations/${app_file_name_without_extension}

	echo "--->> 1 - MEMORY PERFORMANCE TESTING LONG PATH "
	sleep 5
	##### ##### #####  for  performance experiments : preparing the tracer  (for long path)
	echo "--->> Generating the correct tracer source code (not index.ts, but the tracer_x86) script "
	echo "--->> Command: cp  $tracer_index_template_for_performance_experiments $tracer_script_folder/index.ts "
	cp  $tracer_index_template_for_performance_experiments $tracer_script_folder/index.ts 
	echo "--->> Command (verify if short or long is present): cp  $tracer_tracer_template_for_performance_experiments_long_path $tracer_tracer_file_name "
	cp  $tracer_tracer_template_for_performance_experiments_long_path $tracer_tracer_file_name 
	echo "--->> Compiling the tracer"
	(cd $tracer_compilation_folder  && npm run build)
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  performance experiments : instrumenting the application, observing memory  usage
	echo "----- ----- ----- >> command: ./instrument_reinstall_start_and_observe_memory_for_performance.sh $apk_file long $external_storage_folder $number_of_iterations"
	./instrument_reinstall_start_and_observe_memory_for_performance.sh $apk_file long $external_storage_folder $number_of_iterations


	echo "--->> 2 - CPU PERFORMANCE TESTING LONG PATH "
	sleep 5
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  peformance experiments : simply starting  the application, observing  cpu usage
	echo "----- ----- ----- >> command: ./instrument_reinstall_start_and_observe_cpu_for_performance.sh $apk_file long $external_storage_folder $number_of_iterations"
	./instrument_reinstall_start_and_observe_cpu_for_performance.sh $apk_file long $external_storage_folder $number_of_iterations


	

	echo "--->> 3 - MEMORY PERFORMANCE TESTING SHORT PATH "
	sleep 5
	##### ##### #####  for  performance experiments : preparing the tracer  (for short path)
	echo "--->> Generating the correct tracer source code (not index.ts, but the tracer_x86) script "
	echo "--->> Command: cp  $tracer_index_template_for_performance_experiments $tracer_script_folder/index.ts "
	cp  $tracer_index_template_for_performance_experiments $tracer_script_folder/index.ts 
	echo "--->> Command (verify if short or long is present): cp  $tracer_tracer_template_for_performance_experiments_short_path $tracer_tracer_file_name "
	cp  $tracer_tracer_template_for_performance_experiments_short_path $tracer_tracer_file_name 
	echo "--->> Compiling the tracer"
	(cd $tracer_compilation_folder  && npm run build)
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  performance experiments : instrumenting the application, observing memory  usage
	echo "----- ----- ----- >> command: ./instrument_reinstall_start_and_observe_memory_for_performance.sh $apk_file short  $external_storage_folder $number_of_iterations"
	./instrument_reinstall_start_and_observe_memory_for_performance.sh $apk_file short $external_storage_folder $number_of_iterations


	echo "--->> 4 - CPU PERFORMANCE TESTING SHORT PATH "
	sleep 5
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  peformance experiments : simply starting  the application, observing  cpu usage
	echo "----- ----- ----- >> command: ./instrument_reinstall_start_and_observe_cpu_for_performance.sh $apk_file short $external_storage_folder $number_of_iterations"
	./instrument_reinstall_start_and_observe_cpu_for_performance.sh $apk_file short $external_storage_folder $number_of_iterations
	#note command to use adb shell top -b -n 1 | grep com.maxistar


	echo "--->> 5 - BASELINE MEMORY PERFORMANCE TESTING"
	sleep 5
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  baseline experiments :  observing memory  usage
	echo "----- ----- ----- >> command: ./reinstall_start_and_observe_baseline_memory.sh $apk_file $external_storage_folder $number_of_iterations"
	./reinstall_start_and_observe_baseline_memory.sh $apk_file  $external_storage_folder $number_of_iterations


	echo "--->> 5 - BASELINE CPU PERFORMANCE TESTING"
	sleep 5
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
	echo "--->> STARTING EMULATOR"
	if ((./start_emulator.sh) &)  | grep -q 'boot completed'; then
		echo "Emulator started"
	fi
	echo "--->>  EMULATOR STARTED"
	##### ##### ##### for  baseline experiments : simply starting  the application, observing memory and cpu usage
	echo "----- ----- ----- >> command: ./reinstall_start_and_observe_baseline_cpu.sh $apk_file $external_storage_folder $number_of_iterations"
	./reinstall_start_and_observe_baseline_cpu.sh $apk_file  $external_storage_folder $number_of_iterations



	##### ##### ##### Generating plots for short, long, baseline | for memory 
	echo " ----- ----- ----- >> command ./expes_result_overview_tool.py -x $app_memory_experiment_result_folder -P -M -O"   #-P -M for performance memory performances
	( cd android_frida_tools && ./expes_result_overview_tool.py -x $app_memory_experiment_result_folder -P -M -O) 
	#evince "${app_experiment_result_folder}/*.pdf" &

	##### ##### ##### Generating plots for short, long, baseline | for CPU 
	echo " ----- ----- ----- >> command ./expes_result_overview_tool.py -x $app_cpu_experiment_result_folder -P -C -O" #-G -C for performance CPU performances
	( cd android_frida_tools && ./expes_result_overview_tool.py -x $app_cpu_experiment_result_folder -P -C -O) 
	#evince "${app_cpu_experiment_result_folder}/*.pdf" &


	apk_counter=$[$apk_counter+1]

<<EMULATOR-COMMENT
	echo "--->> STOPPING EMULATOR"
	bash stop_emulator.sh
	echo "--->>  EMULATOR STOPPED"
EMULATOR-COMMENT
done

echo "--->>  TEST FINISHED SUCCESSFULLY !!! "

