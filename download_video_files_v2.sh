#!/bin/bash
#######################################
### First check to see if a lockfile exists.
### If not make one. If it does exist exit the script.
### Want to make sure there are not multiple instances running.
#######################################
if test -f /tmp/Blackvue.lockfile
	then
		exit 0
	else
		touch /tmp/Blackvue.lockfile
fi
#--------------------------------------


#######################################
###			Variables
#######################################
videoDirectory=~/Blackvue_Videos
cameraIP="10.99.77.1"			#CameraIP 
cameraSSID="Blackvue900X-SSID"	#Blackvue SSID
cameraPass="password"			#Blackvue Wifi password
#--------------------------------------

mkdir -p "$videoDirectory"	#makes tmp directory if for some reason it doesn't exist
mkdir -p /tmp				#makes tmp directory if for some reason it doesn't exist
cd "$videoDirectory"

#######################################
### Connect to Blackvue Camera
#######################################
###						**** Make sure to change the SSID and PASS ****
function connectToBlackvueWifi {

CurrSSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I|grep "\<SSID\>"|awk '{print $2}')
if [ "$CurrSSID" != "$cameraSSID" ]
	then
		networksetup -setairportpower en1 on
		/usr/sbin/networksetup -setairportnetwork en1 $cameraSSID $cameraPass
	fi
}
#--------------------------------------



#######################################
### Check to see if Camera Wifi is available
### If available then connect using function connectToBlackvueWifi
#######################################
function testSSIDavailable {
if /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | grep $cameraSSID
	then
		connectToBlackvueWifi
	else
		rm /tmp/Blackvue.lockfile	#Delete lockfile so script can run again
		housekeeping
		exit 0 #quit
fi

}
#--------------------------------------


#######################################
### Restest CurrSSID
#######################################
function re-testSSID {
CurrSSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I|grep "\<SSID\>"|awk '{print $2}')
if [ "$CurrSSID" != "$cameraSSID" ]
	then
		break
fi
}
#--------------------------------------


#######################################
### wget video files
#######################################
function downloadVideoClips {
curl http://10.99.77.1/blackvue_vod.cgi | awk 'sub(/^.{2}/,"")' | rev | awk 'sub(/^.{11}/,"")' | rev > /tmp/BlackvueFileList.txt
ls "$videoDirectory" | awk '{ printf "/Record/"; print }'  > /tmp/LocalFileListCompletePath.txt
comm -2 -3 <(sort /tmp/BlackvueFileList.txt) <(sort /tmp/LocalFileListCompletePath.txt) > /tmp/DownloadFrmBlackvue.txt
awk '{ printf "http://$cameraIP"; print }' /tmp/DownloadFrmBlackvue.txt > /tmp/DownloadFrmBlackvueURL.txt

while read -r file;
do
wget -nc --tries=4 --read-timeout=120 http://$cameraIP$file || file2=$(echo $file | awk 'sub(/^.{8}/,"")' ) ; rm $file2 # remove the file if it didn't complete downloading
re-testSSID #if camera becomes unavailable the loop breaks
done < /tmp/DownloadFrmBlackvue.txt
}
#--------------------------------------

#######################################
### Housekeeping
### Move Last Months Clips to a new directory
#######################################
function housekeeping {
today=$(date +%m)
if [[ $today > 15 ]]
	then
		#Date is greater than 15 therefore move older files to their own directory
		#this is done on the 15th and later to prevent re-downloading of the same clips
		stamp=$(date -v-1m +%Y%m) ; mkdir -p "$stamp" #Last Months videos get moved here
		ls "$videoDirectory" | grep "$stamp" | grep ".mp4" | xargs -I '{}' mv '{}' "$stamp"
	fi
}
#--------------------------------------

#######################################
### Run
#######################################

testSSIDavailable
downloadVideoClips
housekeeping


rm /tmp/Blackvue.lockfile	#Delete lockfile so script can run again
exit 0
