cordova create ciccia org.dauvi.ciccia "ciccia"
cd tmp
cordova platform add android
cordova plugin add org.apache.cordova.network-information
cordova plugin add org.apache.cordova.dialogs
cordova plugin add org.apache.cordova.inappbrowser
#cordova plugin add org.apache.cordova.camera
#cordova plugin add org.apache.cordova.geolocation
#cordova plugin add org.apache.cordova.file

cordova build

