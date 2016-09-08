#!/bin/sh
#######################################################
#                                                     #
#   Auto Install OpenLitespeed, CentOS & Percona DB   #
#       Fresh server install CentOS 6x 64bit          #
#    Pastikan Anda dalam user root sebelum install    #
#                 Copyright Bang Den                  #
#             Email  bangden07@gmail.com              #
#######################################################

###########################################################################
# Konfigurasi Passroot mysql, Database, User Database, Pass User Database #
###########################################################################
passrootmysql="ubah pass root mysql"
database="ubah nama database"
userdatabase="ubah user database"
passusermysqlwp="ubah pass user mysql"
###########################################################################

ipserver=`wget http://ipecho.net/plain -O - -q ; echo`

echo "=========================================================="
echo "= Copyright © 2016 Bang Den | Powered By Indo Go Network ="
echo "=========================================================="
echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Sebelum memulai alangkah baiknya kita berdoa kepada YME agar diberi kelancaran  +"
echo "+       Sebelum masuk step 1, kita matikan Iptables & update dulu                 +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cd /
/sbin/service iptables stop
sudo yum -y update
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Tahap 1: Install Repositori Percona Mysql Server +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
sudo yum -y install Percona-Server-client-55 Percona-Server-server-55 Percona-Server-devel-55
echo "Sekarang start mysql"
sudo /etc/init.d/mysql start
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ PERHATIAN !!!                                                 +"
echo "+ 1.Tekan ENTER                                                 +"
echo "+ 2.Ketik Y lalu tekan Enter lalu masukan pass baru untuk Mysql +"
echo "+   Password harus sama dengan konfigurasi (passrootmysql).     +"
echo "+ 3.Ketik Y lalu Enter Semua sampai selesai                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
/usr/bin/mysql_secure_installation
echo "Sekarang restart mysql"
sudo /etc/init.d/mysql restart
echo "+++++++++++++++++++++++++++++++++"
echo "+ Tahap 2: Install EPEL repo 6  +"
echo "+++++++++++++++++++++++++++++++++"
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
echo ""
echo "Berbeda dengan repo Percona, kita harus secara manual mengambil kunci GPG."
wget http://fedoraproject.org/static/0608B895.txt
echo "Lalu hasil download kunci GPG kita pindahkan. Ketik Y lalu ENTER"
mv 0608B895.txt /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
echo ""
echo "+++++++++++++++++++++++++++++++++++++++"
echo "+ Tahap 3: Install Development Tools  +"
echo "+++++++++++++++++++++++++++++++++++++++"
sudo yum -y groupinstall 'Development tools'
sudo yum -y install bzip2-devel curl-devel pcre-devel expat-devel libc-client-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel mhash-devel gd-devel openssl-devel zlib-devel GeoIP-devel
rpm -Uvh http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/x86_64/ius-release-1.0-11.ius.el6.noarch.rpm
echo ""
echo "Sekarang install plugin yum replace"
sudo yum -y install yum-plugin-replace
echo ""
echo "Sekarang kita replace Opensslnya"
sudo yum -y replace openssl --replace-with=openssl10
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Tahap 4: Install OpenLitespeed Repo dan OpenLiteSpeed +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el6.noarch.rpm
sudo yum -y install openlitespeed
echo ""
echo "=========================================="
echo " Seting User dan password OpenLitespeednya"
echo "=========================================="
sudo /usr/local/lsws/admin/misc/admpass.sh
echo ""
echo "Setelah selesai, mulai OpenLiteSpeed dengan perintah"
sudo /usr/local/lsws/bin/lswsctrl start
echo ""
echo "Akhirnya, sedikit pembersihan."
yum clean all
echo ""
echo "==============="
echo " Setup PHP 5.6 "
echo "==============="
sudo yum -y install lsphp56 lsphp56-common lsphp56-gd lsphp56-process lsphp56-mbstring lsphp56-mysql
sudo yum -y install lsphp56-* --skip-broken
sudo ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
echo ""
echo "============="
echo " Setup Mysql "
echo "============="
/etc/init.d/mysql stop
cd /etc/
rm -f myconf.cnf
wget http://www.indogonetwork.com/myconf.txt
mv myconf.txt myconf.cnf
/etc/init.d/mysql start
echo ""
echo "=============================="
echo " Nyalakan kembali IP Tablesnya"
echo "=============================="
/etc/init.d/iptables start
echo "Buat rule juga untuk IP Tablesnya"
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 7080 -j ACCEPT
iptables -P INPUT DROP
/etc/init.d/iptables save
echo "========================================================================"
echo "  OKE FINISH DAN SEKARANG WAKTUNYA BUAT DATABASE DAN INSTALL WORDPRESS  "
echo "========================================================================"
echo ""
echo "Sekarang Install Unzip dan nano apabila belum ada"
yum -y install unzip
yum -y install nano
clear
echo "======  Buat Database wordpress  ======"
mysql -u root -p$passrootmysql -e "CREATE DATABASE $database;GRANT ALL ON $database.* TO $userdatabase@localhost IDENTIFIED BY '$passusermysqlwp';FLUSH PRIVILEGES;exit"
echo "======  Oke Pembuatan database telah selesai  ======"
clear
echo "================================="
echo "  Tahap installasi wordpress gan "
echo "================================="
rm -Rf /usr/local/lsws/Example/html
cd /usr/local/lsws/Example
mkdir html
cd html
sudo wget http://wordpress.org/latest.zip
sudo unzip latest.zip
mv wordpress/* /usr/local/lsws/Example/html/
rm -f latest.zip
rm -Rf wordpress
sudo chown -R nobody:nobody /usr/local/lsws/Example/html/
echo ""
wget http://www.indogonetwork.com/vhconf.txt
rm -f /usr/local/lsws/conf/vhosts/Example/vhconf.conf
mv vhconf.txt /usr/local/lsws/conf/vhosts/Example/vhconf.conf
sudo chown -R lsadm:lsadm /usr/local/lsws/conf/vhosts/Example/vhconf.conf
echo ""
wget http://www.indogonetwork.com/httpd_config.txt
rm -f /usr/local/lsws/conf/httpd_config.conf
mv httpd_config.txt /usr/local/lsws/conf/httpd_config.conf
sudo chown -R lsadm:lsadm /usr/local/lsws/conf/httpd_config.conf
sudo /etc/init.d/lsws restart
echo "======================"
echo "      F I N I S H     "
echo "======================"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+       ________                        __                    +"
echo "+       \______ \   ____   ____ _____ _/  |_  ____            +"
echo "+         |    |  \ /  _ \ /    \\__  \\   __\/ __ \          +"
echo "+         |    |   (  <_> )   |  \/ __ \|  | \  ___/          +"
echo "+        /_______  /\____/|___|  (____  /__|  \___  >         +"
echo "+                \/            \/     \/          \/          +"
echo "+-------------------------------------------------------------+"
echo "+     ITUNG2 BUAT TENAGA, ROKOK, KOPI KONEKSI & PIKIRAN       +"
echo "+                 T E R I M A  K A S I H                      +"
echo "+             PAYPAL  = https://bit.ly/bangden                +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "==============================================================="
echo "= Seting Wordpressnya:                                        "
echo "= Melalui IP: $ipserver / Domain Anda                         "
echo "==============================================================="
