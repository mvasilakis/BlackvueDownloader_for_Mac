# BlackvueDownloader_for_Mac
A simple script to download videos from a Blackvue dash-cam onto a mac using the computers Wifi

To get this to work you will need to have ***wget*** installed. You can follow the instructions here:
https://brew.sh/

Navigate to the Variables section of the download_video_files_v2.sh file and change to suit your camera and video directory. Default uses Blackvue_Videos in your home directory and creates it if it doesn't exist.  
videoDirectory=~/Blackvue_Videos  
cameraIP="10.99.77.1"			#CameraIP  
cameraSSID="Blackvue900X-SSID"	#Blackvue SSID  
cameraPass="password"			#Blackvue Wifi password  

Make the script executable and place it in Documents Scripts if you want to use the provided plist to run this on a schedule.  

***If you want to run it on a schedule***  
Change ***USERNAME*** in com.Blackvue.Download.plist to your username in this line:  
		<string>/Users/USERNAME/Documents/Scripts/download_video_files_v2.sh</string>  
Then place the plist file in your ~/Library/LaunchAgents directory  
This runs the script in 30 min intervals.

What makes this script different than the other available solutions is it looks for the availability of the Blackvue wifi and connects to it if it's not connected.
And of course it runs on an older Mac Mini running Mojave. 




