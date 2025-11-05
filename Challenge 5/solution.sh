#!/bin/bash
set -euo pipefail

########################################
########################################

# 1) Install "mariadb" database server on this server and "start/enable" its service.
dnf install -y mariadb-server*
systemctl enable mariadb || systemctl enable MariaDB
# 2) Set a password for mysql root user to "S3cure#321"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'S3cure#321';"

# 3) Add an extra IP to "eth1" interface on this system: 10.0.0.50/24
ip addr add 10.0.0.50/24 dev eth1

# 4) Add a local DNS entry for "mydb.kodekloud.com" -> "10.0.0.50"
echo "10.0.0.50    mydb.kodekloud.com" >> /etc/hosts

# 5) The "root" account is currently locked on "centos-host", please unlock it. Make user "root" a member of "wheel" group.
passwd -u root
usermod -aG wheel root

# 6) Edit PAM for 'su' to accept only wheel users and accept immediately without password.
sed -i 's/#auth/auth/g' /etc/pam.d/su


####################
####################

# 7.1) Create and run a new Docker container based on "nginx" named "myapp", map host 80 -> container 80
docker pull nginx
docker run -d --name myapp -p 80:80 nginx

# 7.2) Create /home/bob/container-stop.sh (stops myapp and prints message)
cat >/home/bob/container-stop.sh <<'EOF'
#!/bin/bash
sudo docker stop myapp
echo "myapp container stopped!"
EOF
chmod +x /home/bob/container-stop.sh

# 7.3) Create /home/bob/container-start.sh (starts myapp and prints message)
cat >/home/bob/container-start.sh <<'EOF'
#!/bin/bash
sudo docker start myapp
echo "myapp container started!"
EOF
chmod +x /home/bob/container-start.sh

# 7.4) Cron jobs for root: stop at 12am, start at 8am
( crontab -l 2>/dev/null; echo '0 0 * * * /home/bob/container-stop.sh'; echo '0 8 * * * /home/bob/container-start.sh' ) | crontab -
