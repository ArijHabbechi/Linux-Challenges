# User and Group Setup with Permissions

## Task:

Some new developers have joined our team, so we need to create some users/groups and further need to set up some permissions and access rights for them.

## Requirements and Steps:

### 1. Create a group called "devs" :

 ```bash
groupadd devs 
``` 
    

### 2. Create a user called "lisa", change her login shell to `/bin/sh`, and set the password "D3vUd3r123" for this user.
### 3. Make user "lisa" a member of the "devs" group.
        
```bash
useradd -g devs -s /bin/sh lisa
passwd lisa   # Set password: D3vUd3r123 
 ```
        

### 4. Ensure all users under the "devs" group can only run the `dnf` command with `sudo` and without entering any password.

  1.  Open the sudoers file for editing:   `visudo` 
        
  2.  Added the following line to allow members of "devs" group to run `dnf` without a password:  `%devs ALL=(ALL) NOPASSWD: /usr/bin/dnf` 
        

### 5. Configure a "resource limit" for the "devs" group so that this group (members of the group) cannot run more than "30 processes" in their session. This should be both a "hard limit" and a "soft limit", written in a single line.
  Edit the `/etc/security/limits.conf` file to add the process limit for the "devs" group:   `vi /etc/security/limits.conf` 
        
 And add the following line to set both the hard and soft limits for the number of processes: `@devs - nproc 30`
   
   ### 6. Edit the disk quota for the group called "devs". Limit the amount of storage space it can use (not inodes). Set a "soft" limit of "100MB" and a "hard" limit of "500MB" on the `/data` partition.
   
   1.  Check  if the `/data` partition was mounted with quotas enabled:
        `mount | grep '/data'` 
        
    2.  Set quotas for the "devs" group using the `setquota` command:   `setquota -g devs 102400 512000 0 0 /dev/vdb1` 
        

### 7. Create a group called "admins".

-   **Command Executed** `groupadd admins` 
    

### 8. Create a user called "natasha", change her login shell to `/bin/zsh`, and set the password "DwfawUd113" for this user.
```bash
useradd -g admins -s /bin/zsh natasha   
passwd natasha   # Set password: DwfawUd113
```

### 9. Create a user called "david", change his login shell to `/bin/zsh`, and set the password "D3vUd3raaw" for this user.

-   **What I Did**:        
```bash
useradd -g admins -s /bin/zsh david
 passwd david   # Set password: D3vUd3raaw
  ```
      
### 10. Give some additional permissions to the "admins" group on the `/data` directory so that any user who is a member of the "admins" group has full permissions on this directory.
  Set ACLs to give the "admins" group full permissions on the `/data` directory:
        
  ```  bash
sudo setfacl -m g:admins:rwx /data
```
       
### 11. Make sure the `/data` directory is owned by user "bob" and group "devs", and the "user/group" owner has full permissions, but "other" should not have any permissions.
  Changethe ownership of the `/data` directory to user "bob" and group "devs":
  ```bash
  sudo chown bob:devs /data
  ```
        
Set permissions so that user "bob" and group "devs" have full permissions, but others have no permissions:
```bash
sudo chmod 770 /data
```
