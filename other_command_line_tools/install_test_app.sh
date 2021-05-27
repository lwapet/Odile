
#!/bin/bash

echo "######################   testing a appplication using odile GUI ##################################" 

echo "arg1 = $1"
if [ -z "$1" ] 
   then
	echo "No apk path supplied as argument "
: <<'END'
#adb install apks/mz.apk 
adb install apks/CodeDeLaRoute.apk
#adb install apks/washingtonpost.android.apk 
#adb install apks/malicious/locker-0157cdbf66f014deee5dd4f1949b907aac1c8f9f7f4fb90e76ae724e55b05818.apk 
#adb install apks/malicious/locker-002419b9823810ed04ebb0d3b1c3c8b1e296e0ab0526c384183f1423eab0cf77.apk
#adb install apks/malicious/locker-02332cbb5105296f629abaad6a8675c3725690eda91242ec844e8801c0ad1821.apk
#adb install apks/malicious/locker-05439ab5cbc63929b5004a9ef9c42ecf94a9122960073104341c428dc607ea58.apk
#adb install apks/test-frida-agent.apk
END
else
        echo "installing apk $1" 
	adb install $1    
fi




