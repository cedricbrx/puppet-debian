#!/bin/bash

MAC_ADDRESS=`cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address`
#NET-TOOLS needed, please change to a different command from arp
GATEWAY_MAC_ADDRESS=`arp -n $(ip route show default | awk '/default/ {print $3}') | tail -n 1 | awk '{print $3}'`
SYNOLOGY_CLOUD_STATION_ONLINE_VERSION=`curl -s http://dedl.synology.com/download/Tools/CloudStationDrive/ | perl -wlne 'print "$1" if /(\d\.\d.\d-\d\d\d\d)/' | tail -n1`
SYNOLOGY_ASSISTANT_ONLINE_VERSION=`curl -s http://dedl.synology.com/download/Tools/Assistant/ | perl -wlne 'print "$1" if /(\d.\d-\d\d\d\d+)/' | tail -n1`
SYNOLOGY_CLOUD_STATION_VERSION=`dpkg -l synology-cloud-station | awk '{print $3}' | tail -n 1`
SYNOLOGY_ASSISTANT_VERSION=`dpkg -l synology-assistant | awk '{print $3}' | tail -n 1`
PDFMASTER_VERSION=`dpkg -l synology-assistant | awk '{print $3}' | tail -n 1`
PDFMASTER_ONLINE_VERSION=`curl -s https://code-industry.net/what-is-new-in-master-pdf-editor-4/ | perl -wlne 'print "$1" if /(\d\.\d.\d\d)/' | head -n1`
VIDEOCARD_NVIDIA_MODEL=`lspci | grep -i 'VGA compatible controller' | grep -v  -i ASPEED | grep -i NVIDIA | grep 660`
NETWORK_VENDOR=`lspci | grep -i "Ethernet Controller" | tr -s " " | tr "[:upper:]" "[:lower:]" | cut -f4 -d " " | uniq`
WIRELESS_NETWORK_VENDOR=`lspci | grep -i "Network Controller" | tr -s " " | tr "[:upper:]" "[:lower:]" | cut -f4 -d " " | uniq`
REALTEK_NETWORK_R8168=`grep -i "Ethernet Controller" | tr -s " " | cut -f4 -d " " | uniq | grep 8168`

nonfree_firmware_packages="firmware-linux-free firmware-misc-nonfree firmware-linux-nonfree"
if [ $WIRELESS_NETWORK_VENDOR == 'intel' ]; then
     nonfree_firmware_packages+="firmware-iwlwifi"
fi
if [[ $NETWORK_VENDOR == 'realtek' ]] || [[ $WIRELESS_NETWORK_VENDOR == 'realtek' ]] ; then
    nonfree_firmware_packages+="firmware-realtek"
fi
echo firmware_install=$nonfree_firmware_package

if [ $MAC_ADDRESS == '30:85:a9:90:c5:f1' ]; then
    echo set_hostname=mars01
    echo pc_owner=brand10
elif [[ $MAC_ADDRESS == '30:f9:ed:d4:d3:37' ]] || [[ $MAC_ADDRESS == 'b8:76:3f:e3:d3:37' ]]; then
    echo set_hostname=mars02
    echo pc_owner=brand10
elif [[ $MAC_ADDRESS == '123' ]] || [[ $MAC_ADDRESS == '1234' ]]; then
    echo set_hostname=venus01
    echo pc_owner=anne04
else 
    echo set_hostname=brand10
    echo pc_owner=brand10
fi

if [ $GATEWAY_MAC_ADDRESS == 'c8:0e:14:0e:97:27' ]; then
    echo location=beidweiler
elif [ $GATEWAY_MAC_ADDRESS == '' ]; then
    echo location=bonnevoie
else
    echo location=unknown
fi

if [ -z "$SYNOLOGY_CLOUD_STATION_VERSION" ] || [ "$SYNOLOGY_CLOUD_STATION_ONLINE_VERSION" != "$SYNOLOGY_CLOUD_STATION_VERSION" ]; then
    echo synology_cloud_update=true
else
    echo synology_cloud_update=false
fi
echo synology_cloud_version=$SYNOLOGY_CLOUD_STATION_ONLINE_VERSION

if [ -z "$SYNOLOGY_ASSISTANT_VERSION" ] || [ "$SYNOLOGY_ASSISTANT_ONLINE_VERSION" != "$SYNOLOGY_ASSISTANT_VERSION" ]; then
    echo synology_assistant_update=true
else
    echo synology_assistant_update=false
fi
echo synology_assistant_version=$SYNOLOGY_ASSISTANT_ONLINE_VERSION

if [ -z "$PDFMASTER_VERSION" ] || [ "$PDFMASTER_ONLINE_VERSION" != "$PDFMASTER_VERSION" ]; then
    echo codeindustry_pdfmaster_update=true
else
    echo codeindustry_pdfmaster_update=false
fi
echo codeindustry_pdfmaster_version=$PDFMASTER_ONLINE_VERSION

if [ -e /dev/sr0 ]; then 
    echo cdrom_present=true
else 
    echo cdrom_present=false
fi

if [ "$VIDEOCARD_NVIDIA_MODEL" == "660"  ]; then
    echo is_gtx660=true
else
    echo is_gtx660=false
fi

if [ "$REALTEK_NETWORK_R8168" == "r816"  ]; then
    echo is_R8168=true
else
    echo is_R8168=false
fi
