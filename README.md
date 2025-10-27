Provide legacy remi RPM packages
================================

Provide PHP packages that not maintained by remi.


### Setup Repository

Add a repository file to `/etc/yum.repos.d/legacy-remi.repo`, file content as below:

```
[legacy-remi]
name=Legacy Remi repository
baseurl=https://rpms.leoontheearth.me/rpms
enabled=1
gpgcheck=0
```


### Supported PHP versions:

- PHP56


### Supported Linux distributions:

- AlmaLinux 9  
  Required options: `--enablerepo=crb --enablerepo=remi`

- Oracle Linux 9  
  Required options: `--enablerepo=ol9_codeready_builder --enablerepo=remi`
