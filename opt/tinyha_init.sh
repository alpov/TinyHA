#!/bin/sh

rm -f /opt/tinyha/gpio/*

echo 21 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio21/direction
ln -s /sys/class/gpio/gpio21/value /opt/tinyha/gpio/X1
echo 26 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio26/direction
ln -s /sys/class/gpio/gpio26/value /opt/tinyha/gpio/X2
echo 20 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio20/direction
ln -s /sys/class/gpio/gpio20/value /opt/tinyha/gpio/X3
echo 19 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio19/direction
ln -s /sys/class/gpio/gpio19/value /opt/tinyha/gpio/X4
echo 16 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio16/direction
ln -s /sys/class/gpio/gpio16/value /opt/tinyha/gpio/X5
echo 13 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio13/direction
ln -s /sys/class/gpio/gpio13/value /opt/tinyha/gpio/X6
echo 12 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio12/direction
ln -s /sys/class/gpio/gpio12/value /opt/tinyha/gpio/X7
echo 18 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio18/direction
ln -s /sys/class/gpio/gpio18/value /opt/tinyha/gpio/O1
echo 17 > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio17/direction
ln -s /sys/class/gpio/gpio17/value /opt/tinyha/gpio/O2

echo 25 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio25/direction
ln -s /sys/class/gpio/gpio25/value /opt/tinyha/gpio/I1
echo 5 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio5/direction
ln -s /sys/class/gpio/gpio5/value /opt/tinyha/gpio/I2
echo 24 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio24/direction
ln -s /sys/class/gpio/gpio24/value /opt/tinyha/gpio/I3
echo 22 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio22/direction
ln -s /sys/class/gpio/gpio22/value /opt/tinyha/gpio/I4
echo 23 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio23/direction
ln -s /sys/class/gpio/gpio23/value /opt/tinyha/gpio/I5
echo 27 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio27/direction
ln -s /sys/class/gpio/gpio27/value /opt/tinyha/gpio/I6

modprobe ds2482
echo ds2482 0x18 > /sys/bus/i2c/devices/i2c-1/new_device
echo 3 > /sys/bus/w1/devices/w1_bus_master1/w1_master_search
echo 0 > /sys/bus/w1/devices/w1_bus_master1/w1_master_pullup
