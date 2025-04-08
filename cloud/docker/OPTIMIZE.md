**Ubuntu 24.04 Base image size 109 MB**

**Chisel used Ubuntu 24.04 image size 44.8 MB**

| **Test ID** | **Configuration**                                                           | **OLD Size** | **Optimize** | **Test Status (OLD)** | **NEW Size** | **Optimize** | **Test Status (NEW)** | **Optimization Efficiency (MB Saved)** |
|-------------|-----------------------------------------------------------------------------|--------------|--------------|-----------------------|--------------|--------------|-----------------------|----------------------------------------|
|             | **Ubuntu 24.04**                                                           | 109 MB       | 44.8 MB      |                       |              |              |                       |                                        |
| 1           | Unclustered In-memory                                                      | 781 MB       | 425 MB       | PASS                  | 709 MB       | 354 MB       | PASS                  | 72 MB                                  |
| 2           | Unclustered Store-Cassandra                                                 | 1.21 GB      | 913 MB       | PASS                  | 1.13 GB      | 842 MB       | PASS                  | 80 MB                                  |
| 3           | Clustered-As2x, Cache Provider-As2x, Persistence-Store                       | 906 MB       | 595 MB       | PASS                  | 834 MB       | 523 MB       | PASS                  | 72 MB                                  |
| 4           | Clustered-AS2x, Cache Provider-As2x, Persistence-None                        | 901 MB       | 587 MB       | PASS                  | 829 MB       | 516 MB       | PASS                  | 72 MB                                  |
| 5           | Clustered-As2x, Cache Provider-As2x, Persistence-Shared nothing              | 901 MB       | 546 MB       | PASS                  | 829 MB       | 474 MB       | PASS                  | 72 MB                                  |
| 6           | Clustered-FTL, Cache Provider-Ignite, Persistence-None                      | 901 MB       | 583 MB       | PASS                  | 829 MB       | 512 MB       | PASS                  | 72 MB                                  |
| 7           | Clustered-FTL, Cache Provider-Ignite, Persistence-Store                      | 906 MB       | 632 MB       | PASS                  | 834 MB       | 560 MB       | PASS                  | 72 MB                                  |
| 8           | Clustered-FTL, Cache Provider-Ignite, Persistence-Shared nothing             | 901 MB       | 625 MB       | PASS                  | 829 MB       | 553 MB       | PASS                  | 72 MB                                  |
| 9           | Clustered-FTL, Persistence-Store-AS4                                         | 1.21 GB      | 899 MB       | PASS                  | 1.14 GB      | 828 MB       | PASS                  | 70 MB                                  |
| 10          | Clustered-Ignite, Cache Provider-Ignite, Persistence-None                   | 901 MB       | 583 MB       | PASS                  | 829 MB       | 511 MB       | PASS                  | 72 MB                                  |
| 11          | Clustered-Ignite, Cache Provider-Ignite, Persistence-Shared Nothing          | 901 MB       | 624 MB       | PASS                  | 829 MB       | 553 MB       | PASS                  | 72 MB                                  |
| 12          | Clustered-Ignite, Cache Provider-Ignite, Persistence-Store                   | 906 MB       | 631 MB       | PASS                  | 834 MB       | 560 MB       | PASS                  | 72 MB                                  |

***Ubuntu and Chisel used Ubuntu image folders structure with sizes***

| **Folder**  | **Ubuntu Image Size** | **Folder**  | **Chisel Used Ubuntu Image Size** |
|-------------|-----------------------|-------------|-----------------------------------|
| bin         | 20 MB                 | bin         | 16 MB                             |
| dev         | 0                     | dev         | 0                                 |
| etc         | 628 KB                | etc         | 268 KB                            |
| home        | 84 KB                 | home        | 100 KB                            |
| lib         | 43 MB                 | lib         | 13 MB                             |
| lib64       | 4.0 KB                | lib64       | 4 KB                              |
| mnt         | 20 KB                 | mnt         | 20 KB                             |
| opt         | 339 MB                | opt         | 339 MB                            |
| proc        | 0                     | proc        | 0                                 |
| root        | 12 KB                 | root        | 4 KB                              |
| run         | 20 KB                 | run         | 4 KB                              |
| sbin        | 6.7 MB                | sbin        | 44 KB                             |
| sys         | 0                     | sys         | 0                                 |
| tmp         | 4 KB                  | tmp         | 4 KB                              |
| usr         | 73 MB                 | usr         | 31 MB                             |
| var         | 4.5 MB                | var         | 20 KB                             |
| srv         | 4 KB                  |             |                                   |
| boot        | 4 KB                  |             |                                   |
| lib32       | 4 KB                  |             |                                   |
| libx32      | 4 KB                  |             |                                   |
| media       | 4 KB                  |             |                                   |



**I have used chisel library to delete unnecessary folders and files from new image to reduce the image Size**

**Deleted Folders--> srv,boot,lib32,libx32 and media**

**Size Reduced Folders**

Bin Folder-->4 MB

Lib Folder-->30 MB

Sbin Folder-->6.7 MB

Var Folder-->4.5 MB

Usr Folder-->42 MB

**Deleted files list from the above folders**

| **From lib/x86_64-linux-gnu Files/** | **From /bin/ folder** | **From /sbin/ folder** | **From /var/ folder** | **From /usr/ folder** |
|-------------------------------------|-----------------------|------------------------|-----------------------|-----------------------|
| e2fsprogs                           | addpart               | add-shell              | backups               | games                 |
| engines-3                           | apt                   | chpasswd               | local                 | include               |
| gconv                               | apt-cache             | e2image                | lock                  | lib32                 |
| ld-linux-x86-64.so.2               | apt-cdrom             | fsck                   | mail                  | libx32                |
| libBrokenLocale.so.1               | apt-config            | groupmod               | opt                   | local                 |
| libacl.so.1                        | apt-get               | ldconfig.real          | spool                 | src                   |
| libacl.so.1.1.2302                 | apt-key               | mkswap                 |                       |                       |
| libanl.so.1                        | apt-mark              | pwconv                 |                       |                       |
| libapt-pkg.so.6.0                  | base32                | start-stop-daemon      |                       |                       |
| libapt-pkg.so.6.0.0                | basename              | useradd                |                       |                       |
| libapt-private.so.0.0              | bash                  | addgroup               |                       |                       |
| libapt-private.so.0.0.0            | bashbug               | e2label                |                       |                       |
| libassuan.so.0                      | captoinfo             | fsck.cramfs            |                       |                       |
| libassuan.so.0.8.6                  | chage                 | grpck                  |                       |                       |
| libattr.so.1                        | chattr                | logsave                |                       |                       |
| libattr.so.1.1.2502                 | chfn                  | newusers               |                       |                       |
| libaudit.so.1                       | chgrp                 | pwunconv               |                       |                       |
| libaudit.so.1.0.0                   | choom                 | sulogin                |                       |                       |
| libblkid.so.1                       | chrt                  | userdel                |                       |                       |
| libblkid.so.1.1.0                   | chsh                  | adduser                |                       |                       |
| libbz2.so.1                         | clear                 | cpgr                   |                       |                       |
| libbz2.so.1.0                       | clear_console         | e2mmpstatus            |                       |                       |
| libbz2.so.1.0.4                     | cmp                   | fsck.ext2              |                       |                       |
| libc.so.6                           | csplit                | grpconv                |                       |                       |
| libc_malloc_debug.so.0              | dash                  | losetup                |                       |                       |
| libcap-ng.so.0                      | date                  | nologin                |                       |                       |
| libcap-ng.so.0.0.0                  | dd                    | raw                    |                       |                       |
| libcap.so.2                         | deb-systemd-helper    | swaplabel              |                       |                       |
| libcap.so.2.66                      | deb-systemd-invoke    | usermod                |                       |                       |
| libcom_err.so.2                     | debconf               | agetty                 |                       |                       |
| libcom_err.so.2.1                   | debconf-apt-progress  | cppw                   |                       |                       |
| libcrypt.so.1                       | debconf-communicate   | e2scrub                |                       |                       |
| libcrypt.so.1.1.0                   | debconf-copydb        | fsck.ext3              |                       |                       |
| libcrypto.so.3                      | debconf-set-selections | mke2fs                |                       |                       |
| libdb-5.3.so                        | debconf-show          | pam-auth-update        |                       |                       |
| libdebconfclient.so.0               | delpart               | readprofile            |                       |                       |
| libdebconfclient.so.0.0.0           | df                    | swapoff                |                       |                       |
| libdl.so.2                          | diff                  | vigr                   |                       |                       |
| libdrop_ambient.so.0                | diff3                 | badblocks              |                       |                       |
| libdrop_ambient.so.0.0.0            | dir                   | ctrlaltdel             |                       |                       |
| libe2p.so.2                         | dircolors             | e2scrub_all            |                       |                       |
| libe2p.so.2.3                       | dmesg                 | fsck.ext4              |                       |                       |
| libext2fs.so.2                      | dnsdomainname        | hwclock                |                       |                       |
| libext2fs.so.2.4                    | domainname           | mkfs                   |                       |                       |
| libffi.so.8                         | dpkg                  | pam_extrausers_chkpwd  |                       |                       |
| libffi.so.8.1.4                     | dpkg-deb             | remove-shell           |                       |                       |
| libformw.so.6                       | dpkg-divert          | swapon                 |                       |                       |
| libformw.so.6.4                     | dpkg-maintscript-helper | vipw                 |                       |                       |
| libgcc_s.so.1                       | dpkg-query           | blkdiscard             |                       |                       |
| libgcrypt.so.20                     | dpkg-realpath        | debugfs                |                       |                       |
| libgcrypt.so.20.4.3                 | dpkg-split           | e2undo                 |                       |                       |
| libgnutls.so.30                     | dpkg-statoverride     | fsck.minix             |                       |                       |
| libgnutls.so.30.37.1                | dpkg-trigger         | iconvconfig            |                       |                       |
| libgpg-error.so.0                   | du                    | mkfs.bfs               |                       |                       |
| libgpg-error.so.0.34.0              | egrep                 | pam_extrausers_update  |                       |                       |
| libhogweed.so.6                     | expr                  | resize2fs              |                       |                       |
| libhogweed.so.6.8                   | fincore               | switch_root            |                       |                       |
| libidn2.so.0                        | find                  | wipefs                 |                       |                       |
| libidn2.so.0.4.0                    | findmnt               | blkid                  |                       |                       |
| liblz4.so.1                         | flock                 | delgroup               |                       |                       |
| liblz4.so.1.9.4                     | fold                  | e4crypt                |                       |                       |
| liblzma.so.5                        | free                  | fsfreeze               |                       |                       |
| liblzma.so.5.4.5                    | gawk                  | initctl                |                       |                       |
| libm.so.6                           | getconf               | mkfs.cramfs            |                       |                       |
| libmd.so.0                          | getent                | pam_getenv             |                       |                       |
| libmd.so.0.1.0                      | getopt                | rmt                    |                       |                       |
| libmemusage.so                      | gpgv                  | sysctl                 |                       |                       |
| libmenuw.so.6                       | gpasswd              | zic                    |                       |                       |
| libmenuw.so.6.4                     | grep                  | blkzone                |                       |                       |
| libmount.so.1                       | groups                | deluser                |                       |                       |
| libmount.so.1.1.0                   | gunzip                | e4defrag               |                       |                       |
| libmvec.so.1                        | gzexe                 | fstab-decode           |                       |                       |
| libncursesw.so.6                    | hardlink             | installkernel          |                       |                       |
| libncursesw.so.6.4                  | i386                  | mkfs.ext2              |                       |                       |
| libnettle.so.8                      | iconv                 | pam_tally              |                       |                       |
| libnettle.so.8.8                    | id                    | rmt-tar                |                       |                       |
| libnpth.so.0                        | infocmp              | tarcat                 |                       |                       |
| libnpth.so.0.1.2                    | infotocap             | zramctl                |                       |                       |
| libnsl.so.1                         | install              | blockdev               |                       |                       |
| libnss_compat.so.2                  | ionice                | dpkg-preconfigure      |                       |                       |
| libnss_dns.so.2                     | ipcmk                 | faillock               |                       |                       |
| libnss_files.so.2                   | ipcrm                 | fstrim                 |                       |                       |
| libnss_hesiod.so.2                  | ipcs                  | invoke-rc.d            |                       |                       |
| libpam.so.0                         | ischroot              | mkfs.ext3              |                       |                       |
| libpam.so.0.85.1                    | join                  | pam_tally2             |                       |                       |
| libpam_misc.so.0                    | kill                  | rtcwake                |                       |                       |
| libpam_misc.so.0.82.1               | last                  | tune2fs                |                       |                      

**Summary**

**Instead of using multiple RUN commands while install packages I have used single RUN command to reduce the size.

**I have used chisel library to create rootfs with only required files and folders with mentioned package slices in dockerfile to reduce the size.

**Some package slices are not available in chisel library which are required so i have manually copying those folders,commands and libs in the final stage.
