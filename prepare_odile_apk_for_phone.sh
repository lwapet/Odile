#!/bin/bash
# this script copy all files supposed to be in the lib.zip, 
# from their respective locations to the asset folder in the odile app sources

#The project folder
GLOBAL_WORKSPACE="/home/lavoisier/svn_workspace/wapet/security/fridaDroid_final_project"

#the frida config file
FRIDA_CONFIG_FILE=$GLOBAL_WORKSPACE/frida_related_tools/libgadget.config.so_template 

#The gadget so files  
GADGET_SO=$GLOBAL_WORKSPACE/frida_related_tools/gadget_so_files/gadget_arm64.so

#The tracer js file / I suppose you modified+compiled the tracer source code 
#                    knowing that it will work with odile app using tcp calls.  
TRACER_JS=$GLOBAL_WORKSPACE/frida_related_tools/tracers/art-tracer-phone/_agent.js


echo "-----> Adding frida config file, tracer and  gadget.so in assets"
cp $FRIDA_CONFIG_FILE OdileGUI_src/OdileGUI/app/src/main/assets/libgadget.config.so
cp $GADGET_SO OdileGUI_src/OdileGUI/app/src/main/assets/libgadget.so
cp $TRACER_JS OdileGUI_src/OdileGUI/app/src/main/assets/libtracerjs.so

cd OdileGUI_src/OdileGUI


echo "-----> Compiling Odile App"
#gradle build
apk=app/build/outputs/apk/debug/app-debug.apk


pkg=$(aapt dump badging $apk|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(aapt dump badging $apk|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
echo "result : package name : $pkg"
echo "result : start activity name : $act"


echo "-----> Uninstalling Odile GUI"
adb uninstall $pkg


echo "-----> Reinstalling Odile App"
adb install $apk


echo "-----> Starting Odile App"
adb shell am start -n $pkg/$act

cp $apk ../../OdileGUI_for_phone.apk
