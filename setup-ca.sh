#!/usr/bin/env bash

# setup-ca.sh
# Description: This script will setup a TLS Certificate Authority (CA) server.
# Verson: 1.0.0
# Version_Date: 2024-03-28
# Author: John Haverlack (jehaverlack@alaska.edu)
# License: MIT (Proposed/Pending) / UAF Only
# Source: https://github.com/acep-uaf/camio-ca

# This script is intended to be idemopotent.  It can be run multiple times without causing issues.

# Check if dependancy binaries are installed.
req_binaries=(apt awk cat cut date df egrep grep jq lsblk mount sed stat tail tr uname uptime wc which wget)
for i in "${req_binaries[@]}"; do
  if ! which $i > /dev/null 2>&1; then
    echo "Error: $i binary not found or not executable.  Please install $i"
    exit 1
  fi
done

# Verify that this script is being run as root.
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

# Determine the directory full path where this seal-os.sh file is located.
rundir=$(realpath $(dirname $0))

# Check to see if the losd-lib.sh file exists and is readable.
if [ ! -r $rundir/losd/losd-lib.sh ]; then
  echo "Error: $rundir/losd/losd-lib.sh file not found or not readable."
  exit 1
fi

# Defined supported OS
supported_os=("Ubuntu" "Debian")

# Source the losd-lib.sh file.
source $rundir/losd/losd-lib.sh

losd_json=$(losd)

host_name=$(echo $losd_json | jq '.HOST.HOSTNAME' | sed -r 's/"//g')
os_name=$(echo $losd_json | jq '.DISTRO.NAME' | sed -r 's/"//g')
os_version=$(echo $losd_json | jq '.DISTRO.VERSION' | sed -r 's/"//g')
hw_platform=$(echo $losd_json | jq '.HARDWARE.HOSTNAMECTL.Chassis' | tr -dc '[:print:]' | sed -r 's/\s//g' | sed -r 's/"//g')
ip_addr=$(echo $losd_json | jq .HARDWARE.NETWORK | jq -r '.[] | select(.INTERFACE != "lo") | .IPV4_ADDR')

echo ""
echo "Host Name:         $host_name"
echo "OS Name:           $os_name"
echo "OS Version:        $os_version"
echo "Hardware Platform: $hw_platform"
echo "IP Address:        $ip_addr"
echo ""

# Check if the OS is supported
if [[ ! " ${supported_os[@]} " =~ " ${os_name} " ]]; then
    echo "ERROR: Unsupported OS detected: $os_name $os_version"
    exit 1
fi

# Read ca.json

# Check if the ca.json file exists and is readable.
if [ ! -r $rundir/ca.json ]; then
  echo "Error: $rundir/ca.json file not found or not readable."
  exit 1
fi

# Read the ca.json file
ca_json=$(cat $rundir/ca.json | jq)

# Check if the ca.json file is valid JSON
if [ $? -ne 0 ]; then
  echo "Error: $rundir/ca.json file is not valid JSON."
  exit 1
fi

ca_dir=$(echo $ca_json | jq '.CA_DIR' | sed -r 's/"//g')
ca_nets=$(echo $ca_json | jq -r '.NETWORKS[]')
ca_type=$(echo $ca_json | jq '.TYPE' | sed -r 's/"//g')
ca_name=$(echo $ca_json | jq '.PKI_NAME' | sed -r 's/"//g')
ca_dns=$(echo $ca_json | jq '.DNS_NAME' | sed -r 's/"//g')
ca_ipport=$(echo $ca_json | jq '.IP_PORT' | sed -r 's/"//g')
ca_email=$(echo $ca_json | jq '.CA_EMAIL' | sed -r 's/"//g')
ca_password=$(echo $ca_json | jq '.PASSWORD' | sed -r 's/"//g')

echo "CA Directory:      $ca_dir"
# Iterate over each CIDR
echo "CA Networks:"
for CIDR in $ca_nets; do
    echo "   $CIDR"
done
echo "CA Type:           $ca_type"
echo "CA Name:           $ca_name"
echo "CA DNS Name:       $ca_dns"
echo "CA IP Port:        $ca_ipport"
echo "CA Provisioner:    $ca_email"
echo "CA Password:       $ca_password"
echo ""

echo "WARNING:"
echo "This script [setup-ca.sh] will install and configure a TLS Certificate Authority (CA) Server."
read -p "Continue [y/N]:" ans
echo ""

if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
    echo "INFO: Aborting Script."
    exit 1
fi

# ==================== BEGIN CA SETUP SCRIPT ====================

# Install the necessary packages
apt update
apt install -y ufw nginx

# Install Step CLI and Step CA
set -e

trap 'echo "An error occurred. Exiting..." >&2' ERR

# Check if step-cli_amd64.deb and step-ca_amd64.deb are installed
step_cli_deb=$(dpkg -l | grep step-cli)
step_ca_deb=$(dpkg -l | grep step-ca)

if [ -n "$step_cli_deb" ] && [ -n "$step_ca_deb" ]; then
  echo "INFO: step-cli_amd64.deb and step-ca_amd64.deb are already installed."
else
  echo "INFO: Installing step-cli_amd64.deb and step-ca_amd64.deb"
  wget https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb || { echo "Failed to download step-cli_amd64.deb"; exit 1; }
  wget https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb || { echo "Failed to download step-ca_amd64.deb"; exit 1; }
  dpkg -i step-cli_amd64.deb step-ca_amd64.deb || { echo "Failed to install packages"; exit 1; }
fi

# Configure the CA

## Make the CA directory
echo "INFO: Creating CA directory: $ca_dir"
mkdir -p $ca_dir

## Initialize the CA
# echo "INFO: Initializing CA"
# cd $ca_dir

## Check Diretory Location
# pwd

echo "INFO: Setting up CA"
echo "RUNNING: STEPPATH=$ca_dir step ca init --name $ca_name --dns $ca_dns --address $ca_ipport --provisioner $ca_email --password-file <(echo -n $ca_password) --ssh"
STEPPATH=$ca_dir step ca init --name "$ca_name" --dns "$ca_dns" --address "$ca_ipport" --provisioner "$ca_email" --password-file <(echo -n "$ca_password") --ssh


# Firewall Configuration
## Allow SSH, HTTP, and HTTPS from the local network
for CIDR in $ca_nets; do
    ufw allow from $CIDR to any port 22 proto tcp
    ufw allow from $CIDR to any port 80 proto tcp
    ufw allow from $CIDR to any port 443 proto tcp
done

## Enable UFW
ufw enable

# SystemD

## Create the password file
echo $ca_password > $ca_dir/pwfile
chmod 600 $ca_dir/pwfile

## Create a systemd service for the CA
echo "INFO: Creating systemd service for CA"
cp step-ca.service /etc/systemd/system/step-ca.service

echo "INFO: Enabling and starting CA"
systemctl enable step-ca

echo "INFO: Starting CA"
systemctl restart step-ca

echo "INFO: Status of CA"
systemctl status step-ca

# NGINX
echo "INFO: Configuring NGINX"
cp $ca_dir/certs/root_ca.crt "/var/www/html/$ca_dns.crt"

# Set permissions
echo "INFO: Setting permissions"
chmod 444 /var/www/html/$ca_dns.crt

# Summary
echo "The CA has been successfully setup."
echo "The CA is accessible at https://$ca_ipport"
echo "The CA Root Certificate can be found at: http://$ca_dns/$ca_dns.crt"
echo "                                     or: http://$ip_addr/$ca_dns.crt"

# ==================== END CA SETUP SCRIPT ====================
