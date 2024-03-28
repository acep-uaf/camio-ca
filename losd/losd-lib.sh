#!/bin/bash

# Linux OS Version Detector Bash Script
# Description: To provide a universal Linux OS Versions detector for consistent apples to apples os independent comparision using native tool.
# Verson: 1.0.0
# Version_Date: 2023-08-25
# Author: John Haverlack (jehaverlack@alaska.edu)
# License: ISC (Proposed/Pending) / UAF Only
# Source:


# OS Version Check - The following OS's have been tested and are known to work.

function losd () {

  known_os=0

  hostname=`hostname`
  domainname=`domainname -d`
  os_name=''
  os_vers=''
  kern_name=`uname -s`
  kern_vers=`uname -r`
  kern_arch=`uname -m`
  dist_name=''
  dist_vers=''
  install_date=''
  cmiac_dc=''
  cmiac_org=''
  hw_platform=''
  vm_platform=''

# CMIAC
  if [ -r /etc/cmiac/org ]; then
    cmiac_org=`cat /etc/cmiac/org`
  fi

  if [ -r '/etc/cmiac/datacenter' ]; then
    cmiac_dc=`cat /etc/cmiac/datacenter`
  fi


  if [ -r /etc/os-release ]; then
    os_name=`egrep '^NAME' /etc/os-release | cut -d '"' -f2`
    os_vers=`grep VERSION_ID /etc/os-release | cut -d '"' -f2 | sed -r 's/VERSION_ID=//'`
  elif [ -r /etc/centos-release ]; then
    os_name=`cut -d ' ' -f1 /etc/centos-release`
    os_vers=`cut -d ' ' -f3 /etc/centos-release`
  fi

  #echo "DEBUG: $os_name $os_vers"

  case $os_name in
    "Debian GNU/Linux")

      rpiconf=`dpkg -l |grep raspi-config |grep all|awk '{print $2}'`

      if [ "$rpiconf" == "raspi-config" ]; then
        dist_name='Raspbian'
      else
        dist_name='Debian'
      fi

      if [ -r /etc/debian_version ]; then
        dist_vers=`cat /etc/debian_version`
      else
        dist_vers=$os_vers
      fi
      known_os=1

      # install_date=`stat -c %y /var/log/installer`
      install_date=`stat -c %w /`
      ;;

    "Raspbian GNU/Linux")
      dist_name='Raspbian'
      if [ -r /etc/debian_version ]; then
        dist_vers=`cat /etc/debian_version`
      else
        dist_vers=$os_vers
      fi
      known_os=1
      # install_date=`stat -c %y /var/log/installer`
      install_date=`stat -c %w /`
      ;;

    "Ubuntu")
      dist_name=$os_name
      dist_vers=$os_vers
      known_os=1
      # install_date=`stat -c %y /var/log/installer`
      install_date=`stat -c %w /`
      ;;

    "Linux Mint")
      dist_name="LinuxMint"
      dist_vers=$os_vers
      known_os=1
      # install_date=`stat -c %y /var/log/installer`
      install_date=`stat -c %w /`
      ;;

    "CentOS Linux")
      dist_name='CentOS'
      dist_vers=$os_vers
      known_os=1
      install_date=`rpm -qi basesystem|grep 'Install Date:' |cut -d ':' -f2,3,4 | sed -r 's/\s+Build.*$//'`
      # install_date=`stat -c %w /`
      ;;

    "CentOS")
      dist_name=$os_name
      dist_vers=$os_vers
      known_os=1
      install_date=`rpm -qi basesystem|grep 'Install Date:' |cut -d ':' -f2,3,4 | sed -r 's/\s+Build.*$//'`
      # install_date=`stat -c %w /`
      ;;

    "Rocky Linux")
      dist_name='RockyLinux'
      dist_vers=$os_vers
      known_os=1
      # install_date=`rpm -qi basesystem|grep 'Install Date:' |cut -d ':' -f2,3,4 | sed -r 's/\s+Build.*$//'`
      install_date=`stat -c %w /`
      ;;

    "Fedora Linux")
      dist_name='Fedora'
      dist_vers=$os_vers
      known_os=1
      # install_date=`rpm -qi basesystem|grep 'Install Date:' |cut -d ':' -f2,3,4 | sed -r 's/\s+Build.*$//'`
      install_date=`stat -c %w /`
      ;;

    "")
      dist_name='UnknownOS'
      dist_vers="0"
      install_date=`stat -c %w /`
      ;;

    *)
      dist_name=$os_name
      dist_vers=$os_vers
      install_date=`stat -c %w /`
      ;;
  esac

  if [ "$known_os" -ne "1" ]; then
    echo "ERROR: Unknown: $os_name $os_vers"
  fi

  # Hardware

  ramsizekb=`grep MemTotal: /proc/meminfo | sed -r 's/MemTotal:\s+//' | awk '{print $1}'`
  ((ramsizemb = $ramsizekb/1000 ))
  cputype=`grep 'model name' /proc/cpuinfo |tail -n 1 | sed -r 's/model name\s+:\s+//'`
  cpucores=`egrep 'processor\s+:' /proc/cpuinfo |wc -l`

  if [ -z "$cputype" ]; then
    cputype=`grep 'Model' /proc/cpuinfo |tail -n 1 | sed -r 's/Model\s+:\s+//'`
  fi

  awk_bin=`which awk > /dev/null 2>&1`
  awk_bin_status=$?

  lsblk_bin=`which lsblk > /dev/null 2>&1`
  lsblk_bin_status=$?

  binstat=$(( !$lsblk_bin_status && !$awk_bin_status ))

  now=`date -u --iso-8601=seconds`
  timezone=`date +%Z`
  loadavg=`uptime | cut -d : -f5`

  co6test=`echo "$dist_name $dist_vers" | sed -r 's/\.[0-9]+$//'`
  if [ "$co6test" == "CentOS 6" ]; then
    boot_date=''
    uptime=`uptime |cut -d , -f1 | awk '{print $3 " " $4}'`
  else
    boot_date=`uptime -s`
    uptime=`uptime -p`
  fi




  echo '{'
  echo '  "HOST": {'
  echo '    "HOSTNAME": "'$hostname'",'
  echo -n '    "DOMAINNAME": "'$domainname'"'

  if [ "$cmiac_org" != "" ]; then
    echo ','
    echo -n '    "ORGANIZATION": "'$cmiac_org'"'
  # else
  #   echo ''
  fi

  if [ "$cmiac_dc" != "" ]; then
    echo ','
    echo '    "DATACENTER": "'$cmiac_dc'"'
  # else
  #   echo ''
  fi

  echo '   },'
  echo '  "KERNEL": {'
  echo '     "NAME":"'$kern_name'",'
  echo '     "VERSION":"'$kern_vers'",'
  echo '     "ARCH":"'$kern_arch'"'
  echo '   },'
  echo '  "OS": {'
  echo '     "NOW":"'$now'",'
  echo '     "INSTALL_DATE":"'$install_date'",'
  echo '     "LAST_BOOT":"'$boot_date'",'
  echo '     "UPTIME":"'$uptime'",'
  echo '     "TIMEZONE":"'$timezone'",'
  echo '     "LOADAVG":"'$loadavg'"'
  echo '   },'
  echo '  "DISTRO": {'
  echo '     "NAME":"'$dist_name'",'
  echo '     "VERSION":"'$dist_vers'"'
  echo '  },'
  echo '  "HARDWARE": {'
  echo '     "CPU_TYPE":"'$cputype'",'
  echo '     "CPU_CORES":"'$cpucores'",'
  echo '     "MEMORY_MB":"'$ramsizemb'"',

  if [ -f /proc/device-tree/model ]; then
      dev_tree_model=$(tr -d '\0' < /proc/device-tree/model)
      echo '     "DEVICE_MODEL":"'$dev_tree_model'",'
  fi

  echo '     "DISKS": ['

  if [ "$binstat" == '1' ]; then

    disks=`lsblk -l -o MOUNTPOINT |grep -v MOUNTPOINT|grep -v SWAP|grep -v '^$'`
    bdevcount=`lsblk -l -o MOUNTPOINT |grep -v MOUNTPOINT|grep -v SWAP|grep -v '^$' | wc -l`
    bdc=0

    for mp in $disks; do
      bdc=$(( bdc + 1 ))
      if [ "$co6test" == "CentOS 6" ]; then
        blockdev=`mount | grep 'on '$mp' ' | awk '{print $1}'`
        fstype=`mount | grep 'on '$mp' ' | awk '{print $5}'`
        label=`lsblk -o LABEL $blockdev | tail -n 1`
        dflines=`df -B 1M $mp | wc -l`
        if [ "$dflines" == "3" ]; then
          size=`df -B 1M $mp | tail -n 1 | awk '{print $1}' `
          free=`df -B 1M $mp | tail -n 1 | awk '{print $3}' `
        elif [ "$dflines" == "2" ]; then
          size=`df -B 1M $mp | tail -n 1 | awk '{print $2}' `
          free=`df -B 1M $mp | tail -n 1 | awk '{print $4}' `
        fi
      else
        blockdev=`df -h $mp | tail -n 1 | awk '{print $1}' `
        fstype=`lsblk -o FSTYPE $blockdev | tail -n 1`
        label=`lsblk -o LABEL $blockdev | tail -n 1`
        # model=`lsblk -o MODEL $blockdev | tail -n 1`
        size=`df -B 1M $mp | tail -n 1 | awk '{print $2}' `
        free=`df -B 1M $mp | tail -n 1 | awk '{print $4}' `
    fi


      echo '       {'
      echo '         "BLOCKDEV":"'$blockdev'",'
      echo '         "MOUNTPOINT":"'$mp'",'
      echo '         "FS_TYPE":"'$fstype'",'
      echo '         "LABEL":"'$label'",'
      # echo '         "MODEL":"'$model'",'
      echo '         "SIZE_MB":"'$size'",'
      echo '         "FREE_MB":"'$free'"'

      if [ "$bdc" -eq "$bdevcount" ]; then
        echo '       }'
      else
        echo '       },'
      fi

    done

  fi

  echo '     ],'
  echo '     "NETWORK": ['

  interfaces=`ip addr |grep '^[1-9]'|cut -d : -f2 | cut -d '@' -f1`
  ifcount=`ip addr |grep '^[1-9]'|cut -d : -f2 | wc -l`
  ifc=-0

  for i in $interfaces; do
    ifc=$(( ifc + 1 ))

    macaddr=`ip address show dev $i | grep 'link/' | awk '{print $2}'`
    ipv4addr=`ip address show dev $i | grep 'inet ' | awk '{print $2}' | cut -d '/' -f1`
    ipv4prefix=`ip address show dev $i | grep 'inet ' | awk '{print $2}' | cut -d '/' -f2`
    ipv6addr=`ip address show dev $i | grep 'inet6' | awk '{print $2}' | cut -d '/' -f1 | tail -n 1`
    ipv6prefix=`ip address show dev $i | grep 'inet6' | awk '{print $2}' | cut -d '/' -f2 | tail -n 1`
    echo '       {'
    echo '         "INTERFACE":"'$i'",'
    echo '         "MAC_ADDR":"'$macaddr'",'
    echo '         "IPV4_ADDR":"'$ipv4addr'",'
    echo '         "IPV4_PREFIX":"'$ipv4prefix'",'
    echo '         "IPV6_ADDR":"'$ipv6addr'",'
    echo '         "IPV6_PREFIX":"'$ipv6prefix'"'

    if [ "$ifc" -eq "$ifcount" ]; then
      echo '       }'
    else
      echo '       },'
    fi

  done


  hostnamectl_bin=`which hostnamectl > /dev/null 2>&1`
  hostnamectl_bin_status=$?

  if [ "$hostnamectl_bin_status" == '1' ]; then
    echo '     ]'
  else
    echo '     ],'
    echo '     "HOSTNAMECTL": {'
      hncout=`hostnamectl > /var/tmp/hostnamectl.out`
      hcnlines=`cat /var/tmp/hostnamectl.out |wc -l`

      for (( l=1; l<=$hcnlines; l++ )); do
        # echo $l
        key=`head -n $l /var/tmp/hostnamectl.out | tail -n 1 | cut -d ':' -f1 | sed -r 's/^\s+//'`
        val=`head -n $l /var/tmp/hostnamectl.out | tail -n 1 | cut -d ':' -f2 | sed -r 's/^\s+//'`

        if [ "$key" == "Chassis" ]; then
          hw_platform=$val
        fi

        if [ "$key" == "Virtualization" ]; then
          vm_platform=$val
        fi



        if [ "$l" == "$hcnlines" ]; then
          echo '        "'$key'":"'$val'"'
        else
          echo '        "'$key'":"'$val'",'
        fi
      done
      rm -rf /var/tmp/hostnamectl.out
      # echo '     }'
  fi

  if [ "$hw_platform" == "" ]; then
    echo '     }'
  else
    echo '     },'
    echo '     "PLATFORM": {'

    if [ "$hw_platform" == "vm" ]; then
      echo '        "HARDWARE":"'$hw_platform'",'
      case $vm_platform in
        'kvm' )
          if [ "$cmiac_dc" != "" ]; then
            echo '        "VIRT":"ProxMox"'
          else
            echo '        "VIRT":"'$vm_platform'"'
          fi
          ;;
          'oracle' )
            echo '        "VIRT":"VirtualBox"'
          ;;
          'vmware' )
            echo '        "VIRT":"VMWare"'
          ;;
      esac

    else
      echo '        "HARDWARE":"physical"'
    fi
  fi


  user=`whoami`
  # echo 'USERS: '$user
  if [ "$user" == "root" ]; then
    dmidecode_bin=`which dmidecode > /dev/null 2>&1`
    dmidecode_bin_status=$?

    if [ "$dmidecode_bin_status" == '1' ]; then
      echo '     }'
    else
      echo '     },'
      echo '     "DMEIDECODE": {'

      keys=`dmidecode -s  2>&1 |grep -v 'String keyword expected'|grep -v 'Valid string keywords are:' |grep -v 'dmidecode:' | sed -r 's/^\s+//'`
      keycnt=`echo $keys |wc -w`

      kc=1
      for k in $keys; do
        v=`dmidecode -s $k | cut -d ':' -f2 | sed -r 's/^\s+//'`

        if [ "$kc" == "$keycnt" ]; then
          echo '        "'$k'":"'$v'"'
        else
          echo '        "'$k'":"'$v'",'
        fi

        kc=$((kc+1))
      done

      echo '     }'
    fi
  else
      echo '     }'
  fi


  echo '  }'
  echo '}'

}
