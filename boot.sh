[root@dhcp-8-218 ~]# cat boot.sh
ISA_SERIAL_NUM=1
VIRTIO_CONSOLE_NUM=30
VIRTIO_CONSOLE_BUS=20
VIRTIO_SERIAL_BUS=6
VIRTIO_SERIAL_NUM=30
ROOT_PATH=$PWD
IMG_PATH=/mnt/linux
IMG_NAME=RHEL-Server-7.0-64-virtio.qcow2
DISK_IMG=$IMG_PATH/$IMG_NAME
#DISK_IMG=$ROOT_PATH/win8-64-virtio.qcow2
ISO_IMG=/root/virtio-win.iso
NET_SCRIPT=$ROOT_PATH/qemu-ifup-switch

sh mount.sh

cmd+="/usr/libexec/qemu-kvm"
cmd+=" -name 'vm1' "
cmd+=" -nodefaults "
cmd+=" -m 4096"
cmd+=" -smp 4,cores=2,threads=1,sockets=2 "
cmd+=" -vnc :0"
#cmd+=" -usbdevice tablet"
cmd+=" -vga std "
cmd+=" -rtc base=utc,clock=host,driftfix=none  "
cmd+=" -drive file=$DISK_IMG,if=none,cache=none,id=virtio0,snapshot=on "
cmd+=" -device virtio-blk-pci,drive=virtio0 "
cmd+=" -device virtio-net-pci,netdev=id3Ibo2c,mac=9a:5e:5f:60:61:62,vectors=9,mq=on"
cmd+=" -netdev tap,id=id3Ibo2c,sndbuf=123456,script=$NET_SCRIPT,queues=4"
cmd+=" -device ich9-usb-uhci1,id=usb1 "
#cmd+=" -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 "
cmd+=" -boot order=cdn,once=c,menu=on  "
cmd+=" -enable-kvm"
#cmd+=" -M q35"
cmd+=" -monitor stdio "
#cmd+=" -device virtio-balloon-pci,id=ballooning"
cmd+=" -global PIIX4_PM.disable_s3=0"
cmd+=" -global PIIX4_PM.disable_s4=0"
#iso
cmd+=" -drive file=$ISO_IMG,if=none,id=drive-ide0-1-0,media=cdrom,snapshot=off,format=raw"
cmd+="  -device ide-drive,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0 "
cmd+=" -chardev socket,id=qmp_id_qmpmonitor1,path=/tmp/qmpmonitor-1,server,nowait"
cmd+=" -mon chardev=qmp_id_qmpmonitor1,mode=control "
for i in $(seq $ISA_SERIAL_NUM)
do
 cmd+=" -chardev socket,id=isa-serial-$i,path=/tmp/isa-serial-$i,server,nowait"
 cmd+=" -device isa-serial,chardev=isa-serial-$i "
done

for bus in $(seq $VIRTIO_SERIAL_BUS)
do
	cmd+=" -device virtio-serial,id=virt-serial-$bus,max_ports=31,bus=pci.0 "
	for i in $(seq $VIRTIO_SERIAL_NUM)
	do
	  cmd+=" -chardev socket,id=virtio-serial-$bus-$i,path=/tmp/virtio-serial-$bus-$i,server,nowait"
	  #cmd+=" -chardev socket,id=virtio-serial-$i,host=127.0.0.1,port=1234$i,server,nowait"
	  cmd+=" -device virtserialport,chardev=virtio-serial-$bus-$i,name=virtio.serial.$bus.$i,bus=virt-serial-$bus.0,id=virtio-serial-port$bus-$i "
	done
done
for k in $(seq $VIRTIO_CONSOLE_BUS)
do
	cmd+=" -device virtio-serial,id=virt-console-$k"
	for i in $(seq $VIRTIO_CONSOLE_NUM)
	do
	  cmd+=" -chardev socket,id=virtio-console-$k-$i,path=/tmp/virtio-console-$k-$i,server,nowait"
	  cmd+=" -device virtconsole,chardev=virtio-console-$k-$i,name=virtio.console.$k.$i,bus=virt-console-$k.0 "
	done
done
#cmd+=" -chardev socket,id=seabioslog_id_20120821-161618-gMnCW4LE,path=/tmp/seabios-20120821-161618-gMnCW4LE,server,nowait "
#cmd+=" -device isa-debugcon,chardev=seabioslog_id_20120821-161618-gMnCW4LE,iobase=0x402 "


cmd+=" -watchdog ib700"
cmd+=" -watchdog-action pause"
#cmd+=" -chardev socket,path=/tmp/virtio-rng-pci,server,nowait,id=rngpci"
#cmd+=" -device virtio-rng-pci,chardev=rngpci"

#cmd+=" -chardev spicevmc,id=vdagent,debug=0,name=vdagent"
#cmd+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
#cmd+=" -spice port=3000,agent-mouse=on,disable-ticketing"
#cmd+=" -spice port=3000,disable-ticketing"
#cmd+=" -device virtio-rng-pci,chardev=rngpci"
#cmd+=" -sandbox on"
#cmd+=" -device ivshmem,size=128,shm=ivshmem"
#cmd+=" -device virtio-rng-pci"
echo -e $cmd | sed 's/ -/ \\\n-/g'

$cmd
