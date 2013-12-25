NPATH=/tmp/nahanni
ROOTPATH=/home/kvm_autotest_root/images
DISK_IMAGENAME=RHEL-Server-6.2-64-virtio.qcow2
DISK_IMAGE=$ROOTPATH/$DISK_IMAGENAME
#shift
#sleep 3 
qemucmd="qemu-kvm"
qemucmd+=" -name 'vm0' -smp 2 -m 2048 "
qemucmd+=" -drive file=$DISK_IMAGE,if=virtio,media=disk,snapshot=on "
qemucmd+=" -vnc :1 "
#qemucmd+=" -device virtio-net-pci,netdev=mynet0,mac=9a:ce:83:f3:7b:71,id=net0 "
#qemucmd+=" -netdev tap,vhost=on,script=/root/qemu-ifup,id=mynet0 "
qemucmd+=" -enable-kvm -boot c "
until [ $# == 0 ]
do
qemucmd+=" -chardev socket,path=$NPATH,id=nahanni$# "
qemucmd+=" -device ivshmem,chardev=nahanni$#,size=$1,msi=on "
shift
done

echo $qemucmd
echo  $qemucmd | sh &
sleep 1 
vncviewer :1 & 
sleep 3
kill -9 `pidof vncviewer` >/dev/null
kill -9 `pidof qemu-kvm` >/dev/null

#kill -9 `ps axu | grep ivshmem-server | awk '{print $2}'` >/dev/null

#rm -rf /dev/shm/*
