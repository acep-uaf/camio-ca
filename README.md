# camio-ca
Script to setup a local network TLS Certificate Authority using a [step-ca](https://smallstep.com/docs/step-ca/) server.


## Prerequsites
- >= Debian 12 or Ubuntu 22.04 Server

### Options (Nice to Have)
- Static IP Address
- DNS FQDN A Record

> This will work on a DHCP IP and /etc/hosts can be used in lie of DNS for testing purposes.


## Usage

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

