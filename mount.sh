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

ls -l $LOCAL_IMG_PATH | grep "^l" | awk '{print $9}' | sed 's#^#rm -rf '$LOCAL_IMG_PATH/'#g' | sh
ln -s /mnt/linux/* $LOCAL_IMG_PATH
ln -s /mnt/windows/* $LOCAL_IMG_PATH

DISK_IMAGE=$LOCAL_IMG_PATH/$IMAGE_NAME
ISO_IMAGE=$LOCAL_ISO_PATH/$ISO_NAME
IMAGE_NAME=RHEL-Server-7.0-64-virtio.qcow2
ISO_NAME=RHEL6.3-20120606.3-Server-x86_64-DVD1.iso

/usr/libexec/qemu-kvm \
-M pc \
-name 'vm1' \
-drive file=$DISK_IMAGE,index=0,if=none,id=drive-virtio-disk1,media=disk,cache=none,snapshot=on,format=qcow2,aio=native \
-device virtio-blk-pci,bus=pci.0,addr=0x5,drive=drive-virtio-disk1,id=virtio-disk1 \
-device virtio-net-pci,netdev=idKF4XM9,mac=9a:9b:68:24:99:72,id=ndev00idKF4XM9  \
-netdev tap,id=idKF4XM9,vhost=on,queues=4,script=qemu-ifup-vbr0 \
-smp 4,cores=2,threads=1,sockets=4,maxcpus=20 \
-m 4096 \
-vnc :0 \
-boot order=cdn,once=c,menu=on   
