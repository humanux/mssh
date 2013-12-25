#/bin/bash
HOST=$4
PASSWD=redhat
QEMU_BIN=/usr/libexec/qemu-kvm

GUEST_VERSION=$1
GUEST_ARCH=64
GUEST_DIST=linux

GUEST_CPU=$2
GUEST_MEM=$3

ROOT_PATH=$PWD
DISK_IMAGE_PATH=$ROOT_PATH
DISK_FORMAT=qcow2
DISK_INTERFACE=-virtio
DISK_DEVICE=-virtio
IMAGE_NAME=RHEL-Server-${GUEST_VERSION:=6.4}-$GUEST_ARCH$DISK_INTERFACE.$DISK_FORMAT
DISK_IMAGE=$DISK_IMAGE_PATH/$IMAGE_NAME

NETWORK_SCRIPT=$ROOT_PATH/qemu-ifup-switch
ISO_IMAGE_PATH=/home/kvm_autotest_root/iso
ISO_NAME=RHEL$GUEST_VERSION-Server-x86_64.iso
ISO_IMAGE=$ISO_IMAGE_PATH/$GUEST_DIST/$ISO_NAME

CHARDEV_ENABLE=yes
WATCH_DOG_ENABLE=no
WATCH_DOG_ACTION=debug
cmd=$QEMU_BIN
cmd+=" -name vm1 "

#add disk
if [ $DISK_DEVICE == "-virtio" ]
then
	cmd+=" -drive file=$DISK_IMAGE,if=none,format=$DISK_FORMAT,snapshot=on,id=mydisk1 "
	cmd+=" -device virtio-blk,drive=mydisk1 "
elif [ $DISK_DEVICE == "scsi" ]
	cmd+=" -device virtio-scsi-pci,id=virtio_scsi_pci0,addr=0x5"
	then
		for i in {0..3}
	    do
		cmd+=" -drive file=$DISK_IMAGE,if=none,id=virtio-scsi$i,media=disk,snapshot=off,format=qcow2 "
		cmd+=" -device scsi-hd,bus=virtio_scsi_pci0.0,drive=virtio-scsi$i "
	    done
	fi
#add cdrom
cmd+=" -drive file=$ISO_IMAGE,if=none,id=drive-ide0-0-0,media=cdrom,readonly=on,format=raw "
cmd+=" -device ide-drive,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 "

#add cpu and mem
cmd+=" -m ${GUEST_MEM:-1024} -smp ${GUEST_CPU:-2} "

#add vnc
cmd+=" -vnc :4 "
cmd+=" -monitor stdio  "

#add monitor
cmd+=" -chardev socket,id=qmp_monitor1,path=/tmp/monitor-qmpmonitor1,server,nowait "
cmd+=" -mon chardev=qmp_monitor1,mode=control "
#add net
cmd+=" -device virtio-net-pci,netdev=idKF4XM9,mac=9a:9b:68:24:99:72,id=ndev00idKF4XM9 "
cmd+=" -netdev tap,id=idKF4XM9,vhost=on,sndbuf=1048576,script=$NETWORK_SCRIPT "
#cmd+=" -net nic,model=virtio,macaddr=54:53:21:00:12:34 "
#cmd+=" -net user "

#boot option
cmd+=" -boot order=cdn,once=c,menu=on "

#add sandbox
#cmd+=" -sandbox on "
cmd+=" -enable-kvm "

if [ $CHARDEV_ENABLE == "yes" ]
then
	#isa serial
	cmd+=" -chardev socket,id=serial_isa_1,path=/tmp/serial-isa-1,server,nowait "
	cmd+=" -device isa-serial,chardev=serial_isa_1 " 
	
	cmd+=" -chardev socket,id=charserial1,path=/tmp/isa-serial-myserial,server,nowait "
	cmd+=" -device isa-serial,chardev=charserial1,id=serial0   "
	
	cmd+=" -device virtio-serial-pci,id=virtio-serial0,max_ports=31,vectors=8,bus=pci.0  "
	#port ort.port0
	#cmd+=" -chardev socket,id=channel0,path=/tmp/socket-serialport-org.port0,server,nowait "
	#cmd+=" -device virtserialport,bus=virtio-serial0.0,nr=0xF,chardev=channel0,name=org.port0,id=port0  "
	for i in {0..2}
	do
		cmd+=" -chardev socket,path=/tmp/virtserialport0-$i,id=vs1$i,server,nowait "
		cmd+=" -device virtserialport,chardev=vs1$i,name=serialport0-$i,id=serialport0-$i "
	done

	#console
	cmd+=" -device virtio-serial-pci,id=virtio-serial-pci0  "
	for i in {0..1}
	do
		cmd+=" -chardev socket,path=/tmp/virtio-console-$i,id=vc$i,server,nowait "
		cmd+=" -device virtconsole,chardev=vc$i,name=console-$i,id=console-$i,bus=virtio-serial-pci0.0  "
	done

	
	#serialport-2
	cmd+=" -device virtio-serial-pci,id=virtio-serial-pci1 "
	for i in {0..1}
	do
		cmd+=" -chardev socket,path=/tmp/virtio-console1-$i,id=vs2$i,server,nowait "
		cmd+=" -device virtserialport,chardev=vs2$i,name=serialport1-$i,id=serialport1-$i,bus=virtio-serial-pci1.0 "
	done
	#isa debugcon
	cmd+=" -chardev file,path=/tmp/seabios.log,id=seabios "
	cmd+=" -device isa-debugcon,chardev=seabios,iobase=0x402 "
fi
#cmd+=" -chardev msmouse,id=msmouse -device isa-serial,chardev=msmouse"
#cmd+=" -chardev spicevmc,id=vdagent,debug=0,name=vdagent "
#cmd+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0,bus=virtio-serial-pci1.0"
#cmd+=" -spice port=3000,agent-mouse=off"
if [ $WATCH_DOG_ENABLE == 'yes' ]
then
	cmd+=" -device i6300esb "
	cmd+=" -watchdog-action ${WATCH_DOG_ACTION:-reset} "
fi
cmd+=" -global PIIX4_PM.disable_s3=0"
cmd+=" -global PIIX4_PM.disable_s4=0"
cmd+=" -balloon virtio"
cmd+=" -no-shutdown"
cmd+=" -device virtio-rng-pci"
auto_smart_ssh () {
    expect -c "set timeout -1;
                spawn ssh -o StrictHostKeyChecking=no $2 ${@:3};
                expect {
                    *assword:* {send -- $1\r;
                                 expect { 
                                    *denied* {exit 2;}
                                    eof
                                 }
                    }
                    eof         {exit 1;}
                }
                " 
    return $?
}
echo $cmd | sed 's/ -/ \\\n-/g'
 
if [ REMOTE_EXEC == "yes" ]
then
	auto_smart_ssh redhat root@${HOST:-localhost} "$cmd" &

	#cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys >/dev/null
	sleep 5
	ncviewer ${HOST:-localhost} 0 &
	c -U /tmp/monitor-qmpmonitor1
	exit
else
 	$cmd 
fi
