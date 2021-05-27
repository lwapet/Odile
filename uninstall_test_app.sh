

#!/bin/bash

echo "######################   testing a appplication using odile GUI ##################################" 

echo "arg1 = $1"
if [ -z "$1" ] 
   then
	echo "No apk path supplied as argument "
: <<'END'
#adb uninstall at.markushi.reveal
adb uninstall com.Zimbombah.CodeDeLaRoute
#adb uninstall com.washingtonpost.android
#adb uninstall com.anigilyator.org
#adb uninstall com.gnom.anton
#adb uninstall content.app
#adb uninstall com.dual.ops
#adb uninstall com.example.lavoisier.testfridatracer
END
else
        echo "unistalling apk $1" 
        echo "########################  getting the name of the apk ####################################"
	pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
	echo "package name : $pkg"
	adb uninstall $pkg;	    
fi




