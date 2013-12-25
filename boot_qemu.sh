#!/bin/bash

ROOT_PATH=/home/kvm_autotest_root
LOCAL_ISO_PATH=$ROOT_PATH/iso
LOCAL_IMG_PATH=$ROOT_PATH/images
NFS_ADDR=10.66.90.128
NFS_BASE_PATH=/vol/S2/kvmauto
WIN_IMG_PATH=$NFS_ADDR:$NFS_BASE_PATH/windows_img
LUX_IMG_PATH=$NFS_ADDR:$NFS_BASE_PATH/linux_img
ISO_IMG_PATH=$NFS_ADDR:$NFS_BASE_PATH/iso


[ -e $LOCAL_ISO_PATH ] || mkdir -p $LOCAL_ISO_PATH
[ -e $LOCAL_IMG_PATH ] || mkdir -p $LOCAL_IMG_PATH
[ -e /mnt/windows ] || mkdir /mnt/windows
[ -e /mnt/linux ] || mkdir /mnt/linux

grep "$ISO_IMG_PATH $LOCAL_ISO_PATH" /proc/mounts  2>&1 > /dev/null  ||  \
mount $ISO_IMG_PATH $LOCAL_ISO_PATH
grep "$WIN_IMG_PATH /mnt/windows" /proc/mounts  2>&1 > /dev/null || \
mount $WIN_IMG_PATH /mnt/windows
grep "$LUX_IMG_PATH /mnt/linux" /proc/mounts 2>&1 > /dev/null || \
mount $LUX_IMG_PATH  /mnt/linux

#ls -l $LOCAL_IMG_PATH | grep "^l" | awk '{print $9}' | sed 's#^#rm -rf '$LOCAL_IMG_PATH/'#g' | sh
#ln -s /mnt/linux/* $LOCAL_IMG_PATH
#ln -s /mnt/windows/* $LOCAL_IMG_PATH
#

DISTRIBUTION=$1
VERSION=$2
PLATFORM=$3
FORMAT=$4

if [ _${DISTRIBUTION:="l"} == "_l" ]
then
    VER_DIR="linux"
else
    VER_DIR="windows"
fi

IMG_DIR=/mnt/$VER_DIR


select opt in `ls $IMG_DIR/*${VERSION:="6.4"}*${PLATFORM:="64"}*${FORMAT:="qcow2"}`
do
  case $opt in
       *)
       echo $opt;
       if [ -e $opt ]
       then
           IMAGE_NAME=$opt;
       else
           echo "The image not exist";
           exit 1;
       fi
       break
       ;;
  esac
done

#IMAGE_NAME=RHEL-Server-${VERSION:=6.4}-64-virtio.qcow2
#IMAGE_NAME=win7-64-virtio.qcow2
ISO_NAME=windows/winutils.iso
DISK_IMAGE=$IMAGE_NAME
ISO_IMAGE=$LOCAL_ISO_PATH/$ISO_NAME

/usr/libexec/qemu-kvm \
-M pc \
-name 'vm0' \
-chardev socket,id=qmp_monitor1,path=/tmp/qmp_monitor1,server,nowait \
-mon chardev=qmp_monitor1,mode=control \
-drive file=$DISK_IMAGE,index=0,if=none,id=drive-virtio-disk1,media=disk,cache=none,snapshot=on,format=qcow2,aio=native \
-device virtio-blk-pci,bus=pci.0,addr=0x5,drive=drive-virtio-disk1,id=virtio-disk1 \
-drive file=$ISO_IMAGE,if=none,id=iso1,media=cdrom,format=raw \
-device ide-drive,bus=ide.1,unit=0,drive=iso1,id=cdrom1 \
-device rtl8139,netdev=idKF4XM9,mac=9a:9b:68:24:99:73,id=ndev00idKF4XM9  \
-netdev tap,id=idKF4XM9,vhost=on,script=qemu-ifup-switch \
-smp 4,cores=2,threads=1,sockets=4,maxcpus=255 \
-m 4096 \
-vnc :0 \
-monitor stdio \
-boot order=cdn,once=c,menu=on  

