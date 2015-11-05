# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_hid.ko
rmmod g_ether
modprobe libcomposite
mount none /config -t configfs
echo "" > UDC

# New gagdet
mkdir -p /config/usb_gadget/ii
cd /config/usb_gadget/ii

# http://pid.codes/1209/cafe/
echo 0xCAFE > idProduct
echo 0x1209 > idVendor
mkdir -p strings/0x409
echo 01 > strings/0x409/serialnumber
echo ii > strings/0x409/manufacturer
echo iiGadget > strings/0x409/product
# echo "FunctionFS gadget (ptp, adb)" > strings/0x409/product

# our first config
mkdir -p configs/c.1
mkdir -p configs/c.1/strings/0x409
echo "iiKeyboardDiskNet" > configs/c.1/strings/0x409/configuration
#echo 120 > configs/c.1/MaxPower

# our first function, a hid device (keyboard, mouse, joystick)
# should create /dev/hidg0
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 8 > functions/hid.usb0/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.usb0/report_desc
ln -sf functions/hid.usb0 configs/c.1

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_serial.ko
# on host 'screen /dev/ttyACM0 115200
# on device... probably want to run at getty
mkdir -p functions/acm.tty1 #ttyACMX / ttyGSX ?
ln -sf functions/acm.tty1 configs/c.1

# requires  insmod usbserial vendor=<vendorID> product=<productID> on host 8(
#mkdir -p functions/gser.tty2 #ttyUSBX / ttyGSX ?
# Obex looks a bit complicated, and probably not what we want
#mkdir functions/obex.tty3 
#ln -sf functions/gser.tty2 configs/c.1

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_mass_storage.ko
mkdir -p functions/mass_storage.0
echo /root/lun0.img > functions/mass_storage.0/lun.0/file
mkdir -p functions/mass_storage.0/lun.1
echo /root/lun1.img > functions/mass_storage.0/lun.1/file
ln -sf functions/mass_storage.0 configs/c.1

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_ffs.ko

################################################
# PTP https://en.wikipedia.org/wiki/PTPd ?
# mkdir functions/ffs.ptp
# ln -s functions/ffs.ptp configs/c.1
# mkdir /dev/usbffs
# mount ptp /dev/usbffs -t functionfs
# ptpd
###############################################

# ADB (do we want?)
# https://androidonlinux.wordpress.com/2013/05/12/setting-up-adb-on-linux/
# mkdir functions/ffs.adb
# ln -s functions/ffs.adb configs/c.1
# mkdir -p /dev/usbgadget/adb
# mount -t functionfs adb /dev/usbgadget/adb -o uid=2000,gid=2000
# adbd

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_webcam.ko
# mkdir functions/uvc.usb0
# mkdir -p functions/uvc.usb0/streaming/uncompressed/u/360p
# cat <<EOF > functions/uvc.usb0/streaming/uncompressed/u/360p/dwFrameInterval
# 666666
# 1000000
# 5000000
# EOF
# mkdir functions/uvc.usb0/streaming/header/h
# cd functions/uvc.usb0/streaming/header/h
# ln -s ../../uncompressed/u
# cd ../../class/fs
# ln -s ../../header/h
# cd ../../class/hs
# ln -s ../../header/h
# cd ../../../control
# mkdir header/h
# ln -s header/h class/fs
# ln -s header/h class/ss
# cd ../../../
# echo 2048 > functions/uvc.usb0/streaming_maxpacket
# ln -s functions/uvc.usb0 configs/c.1

# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_midi.ko
# This is fun, and can't hurt really
mkdir -p functions/midi.usb0
ln -sf functions/midi.usb0 configs/c.1

# Not sure we can do rndis and ecm at the same time...
# probably confusing to the user
mkdir -p functions/rndis.0
ln -sf functions/rndis.0 configs/c.1

mkdir -p functions/ecm.0
ln -sf functions/ecm.0 configs/c.1

# # ls /sys/class/udc/ #=> musb-hdrc.0.auto
echo musb-hdrc.0.auto > UDC
