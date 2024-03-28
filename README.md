# camio-ca
Script to setup a local network TLS Certificate Authority using a [step-ca](https://smallstep.com/docs/step-ca/) server.


## Prerequsites
- >= Debian 12 or Ubuntu 22.04 Server

### Options (Nice to Have)
- Static IP Address
- DNS FQDN A Record

> This will work on a DHCP IP and /etc/hosts can be used in leu of DNS for testing purposes.

### Using /etc/host in lue of DNS

On your CA server and any TLS CA clients you can add IP entries to your /etc/hosts file like the following.  This will override needing DNS for these entries.

```
192.168.0.100 ca.example.com
192.168.0.102 demo.example.com
```

# Usage

On your Debian or Ubuntu server as root (```sudo su -```):

```
git clone https://github.com/acep-uaf/camio-ca
```

```
cd camio-ca
```

**Copy Example Config**

```
cp example.ca.json ca.json
```

**Edit ca.json**
```
{
  "CA_DIR": "/etc/step-ca",        # step-ca Server Directory
  "NETWORKS": ["CIDR1", "CIDR2"],  # Network CIDR's that need access to this CA
  "TYPE": "Standalone",            # Standalone CA
  "PKI_NAME": "MYCA",              # A name for your CA PKI
  "DNS_NAME": "ca.example.com",    # A FQDN for you CA server 
  "IP_PORT": "IP_ADDR:443",        # The FQDN or IP : HTTPS port 
  "CA_EMAIL": "ca-prov@example.com", # Your Admin Email
  "PASSWORD": "PASSWORD"           # A password to use for the CA
}
```

**Run the setup script**

```
./setup-ca.sh
```


# Fetching the Root Certificate

You can get the Root Certificate from the server on HTTP port 80.

- http://ca.example.com/ca.example.com_ca.crt

> update ca.example.com for you servers FQDN DNS (/etc/hosts) Name.

# Requesting a Certificate from the CA

Once the CA is set up, clients can request a certificate from the CA. Here's how you can do it:

0. Optionally, if you do not have DNS records setup.  Update the /etc/hosts records for each relevant IP.

1. Install the `step-cli` tool on the client machine. This tool is used to interact with the `step-ca` server.

   ```shell
   wget https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb
   sudo dpkg -i step-cli_amd64.deb
   ```


2. Fetch the root certificate from the CA server and install it on the client machine.

   ```
   wget http://ca.example.com/ca.example.com_ca.crt
   sudo step certificate install ca.example.com_ca.crt
   ```

   Replace ca.example.com with the FQDN of your CA server.


3. Request a new certificate from the CA server.

   ```
   step ca certificate "client.example.com" client.crt client.key
   ```

   Replace client.example.com with the FQDN of the client machine. This command will generate a new certificate (client.crt) and a new private key (client.key) for the client machine.

4. Install the new certificate on the client machine.

   ```
   sudo step certificate install client.crt
   ```

   Remember to replace ca.example.com and client.example.com with the actual FQDNs of your CA server and client machine, respectively.

 