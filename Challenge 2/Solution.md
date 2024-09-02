# Challenge 2

## Overview

The app server called centos-host is running a Go app on the 8081 port. You have been asked to troubleshoot some issues with yum/dnf on this system, Install Nginx server, configure Nginx as a reverse proxy for this Go app, install firewalld package and then configure some firewall rules.


Inspect the requirements in detail by clicking on the icons of the interactive architecture diagram on the right and complete the tasks. Once done click on the Check button to validate your work.
Configure Nginx as a reverse proxy for the GoApp so that we can access the GoApp on port "80"

## Solution

### 1. Troubleshoot `yum/dnf` and Resolve DNS Issues

First, I addressed issues with `yum/dnf` by ensuring proper DNS configuration:

```bash
vi /etc/resolv.conf
```

Add the following lines to the file:

`nameserver 8.8.8.8
nameserver 8.8.4.4` 

### 2. Install Necessary Packages

Next, I installed the required packages:

```bash 
yum install nginx -y
yum install firewalld -y 
```

### 3. Start and Enable `firewalld` Service

Start and enable the `firewalld` service to manage firewall rules:

```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
```

### 4. Configure Firewall Rules

Add firewall rules to allow only incoming traffic on ports 22, 80, and 8081. The rules are made permanent and applied immediately:

```bash
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

### 5. Start and Enable Nginx Service

With the firewall configured, I started and enabled the Nginx service:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 6. Configure Nginx as a Reverse Proxy

I then configured Nginx to act as a reverse proxy for the GoApp. The configuration assumes that GoApp is running on `localhost:8081`.

Edit the Nginx configuration:

```bash
vi /etc/nginx/nginx.conf
```

and added the location block `/`, and the following line:
`proxy_pass http://127.0.0.1:8081;` 

### 7. Test and Reload Nginx Configuration

Test the Nginx configuration for any errors and then reload the service to apply the changes:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 8. Start GoApp

Finally, I started the GoApp using the following command:
```bash
cd /home/bob/go-app/
nohup go run main.go &
```