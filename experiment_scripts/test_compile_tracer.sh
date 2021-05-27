#!/bin/bash

#source /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/venv/python3/bin/activate
(cd /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/tracers/art-tracer-emulator  && npm run build)

 ./tracer.py -O -p /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/tracers/art-tracer-emulator/agent/index_template_for_scalability_experiments  -f /media/lavoisier/ee9567d1-e98a-411a-8cea-516195e51630/odile_scalability_evaluation_on_many_apps/methods_loaded_by_apps/input_files_for_experiments_for_locker-0157cdbf66f014deee5dd4f1949b907aac1c8f9f7f4fb90e76ae724e55b05818/800_entries.json  -r /home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project/frida_related_tools/tracers/art-tracer-emulator/agent 
