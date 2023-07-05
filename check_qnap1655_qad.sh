#!/bin/bash

SYSINFO="/sbin/getsysinfo"

CPUTEMPFILE="/share/homes/lunetikk/monitoring/cputemp.txt"
SYSTEMPFILE="/share/homes/lunetikk/monitoring/systemp.txt"
FANFILE="/share/homes/lunetikk/monitoring/fan.txt"
HDFILE="/share/homes/lunetikk/monitoring/hd.txt"
VOLFILE="/share/homes/lunetikk/monitoring/vol.txt"

> $CPUTEMPFILE
> $SYSTEMPFILE
> $FANFILE
> $HDFILE
> $VOLFILE

CPUTEMP=`$SYSINFO cputmp`
SYSTEMP=`$SYSINFO systmp`
SYSFANNR=`$SYSINFO sysfannum`
HDNR=`$SYSINFO hdnum`
SYSVOLNR=`$SYSINFO sysvolnum`

# Get CPUtemperature
if [ -z "$CPUTEMP" ];then
    echo "No CPU temperature received!"
    exit 2
else
    echo "CPUTemp: $CPUTEMP" >> $CPUTEMPFILE
fi

# Get systemtemperature
if [ -z "$SYSTEMP" ];then
    echo "No system temperature received!"
    exit 2
else
    echo "SYSTemp: $SYSTEMP" >> $SYSTEMPFILE
fi

# Get faninfo
if [ "$SYSFANNR" -ge "1" ];then
    for ((i=1; i<=SYSFANNR; i+=1)); do
        SYSFAN=`$SYSINFO sysfan $i`
        echo "Systemfan Nr $i: $SYSFAN" >> $FANFILE
    done
else
    echo "No system fans found!"
    exit 2
fi

# Get diskinfo
if [ "$HDNR" -ge "1" ];then
    for ((j=1; j<=HDNR; j+=1)); do
        HDMODEL=`$SYSINFO hdmodel $j`
        HDCAP=`$SYSINFO hdcapacity $j`
        HDTEMP=`$SYSINFO hdtmp $j`
        HDSTATUS=`$SYSINFO hdstatus $j`
        HDSMART=`$SYSINFO hdsmart $j`
        echo "### DiskNr $j:" >> $HDFILE
        echo "Model: $HDMODEL" >> $HDFILE
        echo "Capacity: $HDCAP" >> $HDFILE
        echo "Temperature: $HDTEMP" >> $HDFILE
        echo "Status: $HDSTATUS" >> $HDFILE
        echo "SMART: $HDSMART" >> $HDFILE
        echo "" >> $HDFILE
    done
else
    echo "No disks found!"
    exit 2
fi

# Get volumeinfo
if [ "$SYSVOLNR" -ge "1" ];then
    for ((k=1; k<=SYSVOLNR; k+=1)); do
        VOLDESC=`$SYSINFO vol_desc $k`
        VOLSTATUS=`$SYSINFO vol_status $k`
        VOLFS=`$SYSINFO vol_fs $k`
        VOLTOTALSIZE=`$SYSINFO vol_totalsize $k`
        VOLFREESIZE=`$SYSINFO vol_freesize $k`
        echo "### Volnr $k:" >> $VOLFILE
        echo "Description: $VOLDESC" >> $VOLFILE
        echo "Status: $VOLSTATUS" >> $VOLFILE
        echo "Filesystem: $VOLFS" >> $VOLFILE
        echo "Totalsize: $VOLTOTALSIZE" >> $VOLFILE
        echo "Freesize: $VOLFREESIZE" >> $VOLFILE
    done
else
    echo "No system volumes found!"
    exit 2
fi
