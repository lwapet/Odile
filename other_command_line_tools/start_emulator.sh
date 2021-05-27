!#/bin/bash
#emulator -wipe-data -avd Nexus_5X_API_27
rm -rv ~/.android/avd/Nexus_5X_API_27.avd/*.lock
#emulator -wipe-data  -read-only -avd Nexus_5X_API_27
emulator -avd Nexus_5X_API_27
#emulator -wipe-data -avd Nexus_5X_API_23
#emulator -wipe-data -avd Nexus_5X_API_25
