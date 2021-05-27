
cd ../OdileApp_src/OdileApp/ 
apk=OdileApp_src/OdileApp/app/build/outputs/apk/debug/app-debug.apk




echo "reinstalling Odile App"

echo "compiling"
#gradle build

pkg=$(aapt dump badging $apk|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(aapt dump badging $apk|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
echo "result : package name : $pkg"
echo "result : start activity name : $act"

echo "Uninstalling"
adb uninstall $pkg
echo "Installing"
adb install $apk
echo "starting"
adb shell am start -n $pkg/$act


