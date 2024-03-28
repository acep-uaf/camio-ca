# uafitss-losd

Linux OS Detector (LOSD) Bash Script

- Description: To provide a universal Linux OS Versions detector with minimal dependencies for consistent apples to apples os independent comparison using native tools across a wide range of Linux distributions.
- Verson: 1.0.0
- Version_Date: 2023-08-25
- Author: John Haverlack (jehaverlack@alaska.edu)
- License: ISC (Proposed/Pending) / UAF Only
- Source:


# Files
- losd-lib.sh - LOSD Bash Library
- losd.sh - Example Bash Script

# Tested Distributions
- Debian 11
- Ubuntu 22
- LinuxMint 21
- Raspbian 11
- CentOS 6
- CentOS 7
- RockyLinux 9
- AlmaLinux 9
- Fedora 36

# Usage

## Basic Install

```
git clone
```

```
cd cfosit-linux-os-detector
./losd.sh
```

---

- These scripts assume the **losd-lib.sh** library is located in the same directory as your bash script.  Otherwise modify the source path to the **losd-lib.sh** library path.

## Simple Bash Script

```
#!/bin/bash

rundir=`echo $0 | sed -r 's/\/losd.sh//'`
source $rundir/losd-lib.sh

losd
```

## Example with search filter

And example bash script called **losd.sh** which is located in the same directory as the **losd-lib.sh** library.
```
#!/bin/bash

rundir=`echo $0 | sed -r 's/\/losd.sh//'`
source $rundir/losd-lib.sh

filter=$1

# If the jq (JSON Query) Binary is installed fitler with js.
jq_bin=`which jq`
isjq=$?

# Filter
# echo $filter
if [ "$isjq" == "0" ]; then
  losd_json=$(losd)
  if [ $filter ]; then
    echo $losd_json | jq $filter | sed -r 's/"//g'
  else
    echo $losd_json | jq
  fi
else
  if [ $filter ]; then
    losd | grep $filter | cut -d ':' -f2 | sed -r 's/"//g' | sed -r 's/,$//'
  else
    losd
  fi
fi
```

### Sample Output of **losd.sh**
```
{
  "HOST": {
    "HOSTNAME": "jehaverlack-nuc",
    "DOMAINNAME": "(none)"
  },
  "KERNEL": {
    "NAME": "Linux",
    "VERSION": "5.10.0-19-amd64",
    "ARCH": "x86_64"
  },
  "OS": {
    "NOW": "2022-12-23T01:27:01+00:00",
    "INSTALLED": "2022-04-22 02:55:45.000000000 -0800",
    "LASTBOOTED": "2022-12-09 08:41:40",
    "UPTIME": "up 1 week, 6 days, 7 hours, 45 minutes",
    "TIMEZONE": "AKST",
    "LOADAVG": " 2.49, 2.09, 1.83"
  },
  "DISTRO": {
    "NAME": "Debian",
    "VERSION": "11.6"
  },
  "HARDWARE": {
    "CPU_TYPE": "Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz",
    "CPU_CORES": "12",
    "MEMORY_MB": "65568",
    "DISKS": [
      {
        "BLOCKDEV": "/dev/sda1",
        "MOUNTPOINT": "/media/jehaverlack/Backup",
        "FS_TYPE": "ntfs",
        "LABEL": "Backup",
        "SIZE_MB": "1907695",
        "FREE_MB": "1565914"
      },
      {
        "BLOCKDEV": "/dev/nvme0n1p1",
        "MOUNTPOINT": "/boot/efi",
        "FS_TYPE": "vfat",
        "LABEL": "NO_LABEL",
        "SIZE_MB": "300",
        "FREE_MB": "296"
      },
      {
        "BLOCKDEV": "/dev/nvme0n1p2",
        "MOUNTPOINT": "/",
        "FS_TYPE": "ext4",
        "LABEL": "",
        "SIZE_MB": "890699",
        "FREE_MB": "647695"
      }
    ],
    "NETWORK": [
      {
        "INTERFACE": "lo",
        "MAC_ADDR": "00:00:00:00:00:00",
        "IPV4_ADDR": "127.0.0.1",
        "IPV4_PREFIX": "8",
        "IPV6_ADDR": "::1",
        "IPV6_PREFIX": "128"
      },
      {
        "INTERFACE": "eno1",
        "MAC_ADDR": "1c:69:7a:ab:c5:89",
        "IPV4_ADDR": "10.25.187.253",
        "IPV4_PREFIX": "23",
        "IPV6_ADDR": "fe80::99e:3470:e02a:3385",
        "IPV6_PREFIX": "64"
      },
      {
        "INTERFACE": "wlp0s20f3",
        "MAC_ADDR": "06:c9:1e:f4:8e:a2",
        "IPV4_ADDR": "",
        "IPV4_PREFIX": "",
        "IPV6_ADDR": "",
        "IPV6_PREFIX": ""
      },
      {
        "INTERFACE": "tun0",
        "MAC_ADDR": "",
        "IPV4_ADDR": "",
        "IPV4_PREFIX": "",
        "IPV6_ADDR": "fe80::2135:1646:23b6:b4f9",
        "IPV6_PREFIX": "64"
      }
    ],
    "HOSTNAMECTL": {
      "Static hostname": "jehaverlack-nuc",
      "Icon name": "computer-desktop",
      "Chassis": "desktop",
      "Machine ID": "4312e4586fa440a1a65e591a484f1d68",
      "Boot ID": "cf7b4a38821d4731958dc9ee9dbd8125",
      "Operating System": "Debian GNU/Linux 11 (bullseye)",
      "Kernel": "Linux 5.10.0-19-amd64",
      "Architecture": "x86-64"
    },
    "DMEIDECODE": {
      "bios-vendor": "Intel Corp.",
      "bios-version": "FNCML357.0055.2021.1202.1748",
      "bios-release-date": "12/02/2021",
      "bios-revision": "5.16",
      "firmware-revision": "3.9",
      "system-manufacturer": "Intel(R) Client Systems",
      "system-product-name": "NUC10i7FNH",
      "system-version": "M38010-308",
      "system-serial-number": "G6FN137005EH",
      "system-uuid": "4232acae-4f8e-c192-ce1d-1c697aabc589",
      "system-sku-number": "BXNUC10i7FNHN",
      "system-family": "FN",
      "baseboard-manufacturer": "Intel Corporation",
      "baseboard-product-name": "NUC10i7FNB",
      "baseboard-version": "M38062-307",
      "baseboard-serial-number": "GEFN13500F9X",
      "baseboard-asset-tag": "Default string",
      "chassis-manufacturer": "Intel Corporation",
      "chassis-type": "Mini PC",
      "chassis-version": "2.0",
      "chassis-serial-number": "Default string",
      "chassis-asset-tag": "Default string",
      "processor-family": "Core i7",
      "processor-manufacturer": "Intel(R) Corporation",
      "processor-version": "Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz",
      "processor-frequency": "1100 MHz"
    }
  }
}
```
**NOTE:** DMEIDECODE requires **losd.sh** to be run as root or with sudo.


### Sample Output of **losd.sh** filtering for MEMORY_MB on a system with the [_jq_](https://stedolan.github.io/jq/) binary in the path
```
[prompt $] ./losd.sh .HARDWARE.MEMORY_MB
65568
```

### Sample Output of **losd.sh** filtering for MEMORY_MB on a system without the [_jq_](https://stedolan.github.io/jq/) binary in the path
```
[prompt $] ./losd.sh MEMORY_MB
999
```
