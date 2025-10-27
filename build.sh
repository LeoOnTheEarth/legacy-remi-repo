#!/bin/bash

set -x

RPM_BUILD_DIR=$HOME/rpmbuild
BUILD_DIR=$HOME/build-remi-rpms
MOCK_CONFIG=almalinux-9-x86_64
MOCK_RESULT_DIR=/var/lib/mock/$MOCK_CONFIG/result
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd -P )

mkdir $BUILD_DIR
mkdir $BUILD_DIR/rpms
mkdir $BUILD_DIR/srpms
mkdir $BUILD_DIR/patches

cp $SCRIPT_DIR/files/patches/* $BUILD_DIR/patches

sudo dnf -y install epel-release
sudo dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo dnf config-manager --set-enabled crb
sudo dnf config-manager --set-enabled remi
sudo dnf -y update
sudo dnf -y install rpm-build mock createrepo_c diffutils patch wget git
sudo dnf clean all
sudo rm -rf /var/cache/dnf
createrepo_c $BUILD_DIR/rpms

sudo cp $SCRIPT_DIR/files/mock/$MOCK_CONFIG.cfg /etc/mock/$MOCK_CONFIG.cfg

# Create SRPM for compat-openssl11
cd $BUILD_DIR
wget http://vault.almalinux.org/9.6/AppStream/Source/Packages/compat-openssl11-1.1.1k-5.el9_6.1.src.rpm
rpm -i compat-openssl11-1.1.1k-5.el9_6.1.src.rpm
cd $RPM_BUILD_DIR/SPECS
patch -i $BUILD_DIR/patches/compat-openssl11.spec.patch
rpmbuild -bs compat-openssl11.spec
cp $RPM_BUILD_DIR/SRPMS/compat-openssl11-1.1.1k-5.el9.1.src.rpm $BUILD_DIR/srpms
rm $BUILD_DIR/compat-openssl11-1.1.1k-5.el9_6.1.src.rpm
rm -rf $RPM_BUILD_DIR

# Create SRPM for php
cd $BUILD_DIR
wget https://rpms.remirepo.net/SRPMS/php56-php-5.6.40-45.remi.src.rpm
rpm -i php56-php-5.6.40-45.remi.src.rpm
cd $RPM_BUILD_DIR/SPECS
patch -i $BUILD_DIR/patches/php.spec.patch
rpmbuild -bs php.spec
cp $RPM_BUILD_DIR/SRPMS/php-5.6.40-45.el9.src.rpm $BUILD_DIR/srpms
rm $BUILD_DIR/php56-php-5.6.40-45.remi.src.rpm
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-fedora-autoloader
cd $BUILD_DIR
wget https://rpms.remirepo.net/SRPMS/php-fedora-autoloader-1.0.1-2.remi.src.rpm
rpm -i php-fedora-autoloader-1.0.1-2.remi.src.rpm
cd $RPM_BUILD_DIR/SPECS
patch -i $BUILD_DIR/patches/php-fedora-autoloader.spec.patch
rpmbuild -bs php-fedora-autoloader.spec
cp $RPM_BUILD_DIR/SRPMS/php-fedora-autoloader-1.0.1-2.el9.src.rpm $BUILD_DIR/srpms
rm $BUILD_DIR/php-fedora-autoloader-1.0.1-2.remi.src.rpm
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-apcu
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-apcu.git
cd $BUILD_DIR/php-pecl-apcu
git checkout -b php5 origin/php5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-apcu/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-apcu.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/apcu-4.0.11.tgz
cd $RPM_BUILD_DIR/SPECS
rpmbuild -bs php-pecl-apcu.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-apcu-4.0.11-3.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-apcu
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-luasandbox
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-luasandbox.git
cd $BUILD_DIR/php-pecl-luasandbox
git checkout -b php5 51bd8640633a4d26f39ad3ce24d6259059295ee5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-luasandbox/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-luasandbox.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/LuaSandbox-3.0.3.tgz
cd $RPM_BUILD_DIR/SPECS
rpmbuild -bs php-pecl-luasandbox.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-luasandbox-3.0.3-2.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-luasandbox
rm -rf $RPM_BUILD_DIR
   
# Create SRPM for php-pecl-memcache
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-memcache.git
cd $BUILD_DIR/php-pecl-memcache
git checkout -b php5 origin/php5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-memcache/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-memcache.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/memcache-3.0.8.tgz
cd $RPM_BUILD_DIR/SPECS 
rpmbuild -bs php-pecl-memcache.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-memcache-3.0.8-9.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-memcache
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-igbinary
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-igbinary.git
cd $BUILD_DIR/php-pecl-igbinary
git checkout -b v2 origin/v2
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-igbinary/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-igbinary.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/igbinary-2.0.8.tgz
cd $RPM_BUILD_DIR/SPECS
rpmbuild -bs php-pecl-igbinary.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-igbinary-2.0.8-1.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-igbinary
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-msgpack
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-msgpack.git
cd $BUILD_DIR/php-pecl-msgpack
git checkout -b php5 origin/php5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-msgpack/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-msgpack.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/msgpack-0.5.7.tgz
cd $RPM_BUILD_DIR/SPECS
patch -i $BUILD_DIR/patches/php-pecl-msgpack.spec.patch
rpmbuild -bs php-pecl-msgpack.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-msgpack-0.5.7-3.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-msgpack
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-memcached
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-memcached.git
cd $BUILD_DIR/php-pecl-memcached
git checkout -b php5 origin/php5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-memcached/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-memcached.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://pecl.php.net/get/memcached-2.2.0.tgz
cd $RPM_BUILD_DIR/SPECS
rpmbuild -bs php-pecl-memcached.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-memcached-2.2.0-10.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-memcached
rm -rf $RPM_BUILD_DIR

# Create SRPM for php-pecl-xdebug
cd $BUILD_DIR
git clone https://git.remirepo.net/cgit/rpms/php/pecl/php-pecl-xdebug.git
cd $BUILD_DIR/php-pecl-xdebug
git checkout -b v2.5 origin/v2.5
mkdir -p $RPM_BUILD_DIR/SOURCES
mkdir -p $RPM_BUILD_DIR/SPECS
cp $BUILD_DIR/php-pecl-xdebug/* $RPM_BUILD_DIR/SOURCES
mv $RPM_BUILD_DIR/SOURCES/php-pecl-xdebug.spec $RPM_BUILD_DIR/SPECS
cd $RPM_BUILD_DIR/SOURCES
wget https://github.com/xdebug/xdebug/archive/36b4f952ca3196a2300a1ebac1716523dd84d19b/xdebug-2.5.5-36b4f95.tar.gz
cd $RPM_BUILD_DIR/SPECS
rpmbuild -bs php-pecl-xdebug.spec
cp $RPM_BUILD_DIR/SRPMS/php-pecl-xdebug-2.5.5-4.el9.src.rpm $BUILD_DIR/srpms
rm -rf $BUILD_DIR/php-pecl-xdebug
rm -rf $RPM_BUILD_DIR

# Download other SRPMs
cd $BUILD_DIR/srpms
wget https://rpms.remirepo.net/SRPMS/php56-5.6-1.remi.src.rpm
wget https://rpms.remirepo.net/SRPMS/php-pear-1.10.13-5.remi.src.rpm
wget https://rpms.remirepo.net/SRPMS/php-pecl-jsonc-1.3.10-3.remi.src.rpm
wget https://rpms.remirepo.net/SRPMS/php-pecl-zip-1.22.7-1.remi.src.rpm
wget https://rpms.remirepo.net/SRPMS/php-pecl-imagick-im7-3.8.0-3.remi.src.rpm
wget https://rpms.remirepo.net/SRPMS/php-pecl-redis4-4.3.0-4.remi.src.rpm

# Build compat-openssl11
sudo mock -r $MOCK_CONFIG --rebuild $BUILD_DIR/srpms/compat-openssl11-1.1.1k-5.el9.1.src.rpm
ls -al $MOCK_RESULT_DIR
cp $MOCK_RESULT_DIR/compat-openssl11-1.1.1k-5.el9.1.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/compat-openssl11-devel-1.1.1k-5.el9.1.x86_64.rpm $BUILD_DIR/rpms
createrepo_c --update $BUILD_DIR/rpms

# Build php56
sudo mock -r $MOCK_CONFIG --define "scl php56" --define "scl_vendor remi" --define "rh_layout 1" --rebuild $BUILD_DIR/srpms/php56-5.6-1.remi.src.rpm
ls -al $MOCK_RESULT_DIR
cp $MOCK_RESULT_DIR/php56-5.6-1.el9.x86_64.rpm          $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-build-5.6-1.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-runtime-5.6-1.el9.x86_64.rpm  $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-scldevel-5.6-1.el9.x86_64.rpm $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-syspaths-5.6-1.el9.x86_64.rpm $BUILD_DIR/rpms
createrepo_c --update $BUILD_DIR/rpms

# Build php56-php (bootstrap)
sudo mock -r $MOCK_CONFIG --define "scl php56" --define "scl_vendor remi" --define "rh_layout 1" --with bootstrap --rebuild $BUILD_DIR/srpms/php-5.6.40-45.el9.src.rpm
ls -al $MOCK_RESULT_DIR
cp $MOCK_RESULT_DIR/php56-php-5.6.40-45.el9~bootstrap.x86_64.rpm           $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-bcmath-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-cli-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-common-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-dba-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-dbg-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-devel-5.6.40-45.el9~bootstrap.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-embedded-5.6.40-45.el9~bootstrap.x86_64.rpm  $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-enchant-5.6.40-45.el9~bootstrap.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-fpm-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-gd-5.6.40-45.el9~bootstrap.x86_64.rpm        $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-gmp-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-imap-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-interbase-5.6.40-45.el9~bootstrap.x86_64.rpm $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-intl-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-ldap-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-litespeed-5.6.40-45.el9~bootstrap.x86_64.rpm $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mbstring-5.6.40-45.el9~bootstrap.x86_64.rpm  $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mcrypt-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mssql-5.6.40-45.el9~bootstrap.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mysqlnd-5.6.40-45.el9~bootstrap.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-odbc-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-opcache-5.6.40-45.el9~bootstrap.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pdo-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pgsql-5.6.40-45.el9~bootstrap.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-process-5.6.40-45.el9~bootstrap.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pspell-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-recode-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-snmp-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-soap-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-tidy-5.6.40-45.el9~bootstrap.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-xml-5.6.40-45.el9~bootstrap.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-xmlrpc-5.6.40-45.el9~bootstrap.x86_64.rpm    $BUILD_DIR/rpms
createrepo_c --update $BUILD_DIR/rpms

# Build php56-php-pear
sudo mock -r $MOCK_CONFIG --define "scl php56" --define "scl_vendor remi" --define "rh_layout 1" --rebuild $BUILD_DIR/srpms/php-pear-1.10.13-5.remi.src.rpm
ls -al $MOCK_RESULT_DIR
cp $MOCK_RESULT_DIR/php56-php-pear-1.10.13-5.el9.noarch.rpm $BUILD_DIR/rpms
createrepo_c --update $BUILD_DIR/rpms

build_pecl_package() {
  local srpm=$1
  local export_rpms=(${!2})

  sudo mock -r $MOCK_CONFIG --clean
  sudo mock -r $MOCK_CONFIG --init --dnf
  sudo mock -r $MOCK_CONFIG --install php56-build-5.6-1.el9.x86_64 --install php56-scldevel-5.6-1.el9.x86_64 --install php56-syspaths-5.6-1.el9.x86_64
  sudo mock -r $MOCK_CONFIG --no-clean --define "scl php56" --define "scl_vendor remi" --define "rh_layout 1" --define "vendeur remi" \
    --rebuild $BUILD_DIR/srpms/$srpm
  ls -al $MOCK_RESULT_DIR
  for filename in ${export_rpms[@]}; do
    cp "$MOCK_RESULT_DIR/$filename" $BUILD_DIR/rpms
  done

  createrepo_c --update $BUILD_DIR/rpms
}

# Build php56-php-pecl-jsonc
export_rpms=("php56-php-pecl-jsonc-1.3.10-3.el9.x86_64.rpm" "php56-php-pecl-jsonc-devel-1.3.10-3.el9.x86_64.rpm")
build_pecl_package "php-pecl-jsonc-1.3.10-3.remi.src.rpm" export_rpms[@]

# Build php56-php-pecl-zip
export_rpms=("php56-php-pecl-zip-1.22.7-1.el9.x86_64.rpm")
build_pecl_package "php-pecl-zip-1.22.7-1.remi.src.rpm" export_rpms[@]

# Build php56-php-pecl-apcu
export_rpms=("php56-php-pecl-apcu-4.0.11-3.el9.x86_64.rpm" "php56-php-pecl-apcu-devel-4.0.11-3.el9.x86_64.rpm")
build_pecl_package "php-pecl-apcu-4.0.11-3.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-igbinary
export_rpms=("php56-php-pecl-igbinary-2.0.8-1.el9.5.6.x86_64.rpm" "php56-php-pecl-igbinary-devel-2.0.8-1.el9.5.6.x86_64.rpm")
build_pecl_package "php-pecl-igbinary-2.0.8-1.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-msgpack
export_rpms=("php56-php-pecl-msgpack-0.5.7-3.el9.x86_64.rpm" "php56-php-pecl-msgpack-devel-0.5.7-3.el9.x86_64.rpm")
build_pecl_package "php-pecl-msgpack-0.5.7-3.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-imagick-im7
export_rpms=("php56-php-pecl-imagick-im7-3.8.0-3.el9.x86_64.rpm" "php56-php-pecl-imagick-im7-devel-3.8.0-3.el9.x86_64.rpm")
build_pecl_package "php-pecl-imagick-im7-3.8.0-3.remi.src.rpm" export_rpms[@]

# Build php56-php-pecl-luasandbox
export_rpms=("php56-php-pecl-luasandbox-3.0.3-2.el9.x86_64.rpm")
build_pecl_package "php-pecl-luasandbox-3.0.3-2.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-memcache
export_rpms=("php56-php-pecl-memcache-3.0.8-9.el9.5.6.x86_64.rpm")
build_pecl_package "php-pecl-memcache-3.0.8-9.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-memcached
export_rpms=("php56-php-pecl-memcached-2.2.0-10.el9.x86_64.rpm")
build_pecl_package "php-pecl-memcached-2.2.0-10.el9.src.rpm" export_rpms[@]

# Build php56-php-pecl-redis4
export_rpms=("php56-php-pecl-redis4-4.3.0-4.el9.x86_64.rpm")
build_pecl_package "php-pecl-redis4-4.3.0-4.remi.src.rpm" export_rpms[@]

# Build php56-php-pecl-xdebug
export_rpms=("php56-php-pecl-xdebug-2.5.5-4.el9.x86_64.rpm")
build_pecl_package "php-pecl-xdebug-2.5.5-4.el9.src.rpm" export_rpms[@]

rm -rf $BUILD_DIR/rpms/php56-php-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-bcmath-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-cli-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-common-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-dba-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-dbg-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-devel-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-embedded-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-enchant-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-fpm-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-gd-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-gmp-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-imap-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-interbase-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-intl-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-ldap-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-litespeed-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-mbstring-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-mcrypt-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-mssql-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-mysqlnd-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-odbc-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-opcache-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-pdo-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-pgsql-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-process-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-pspell-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-recode-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-snmp-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-soap-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-tidy-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-xml-5.6.40-45.el9~bootstrap.x86_64.rpm
rm -rf $BUILD_DIR/rpms/php56-php-xmlrpc-5.6.40-45.el9~bootstrap.x86_64.rpm
createrepo_c --update $BUILD_DIR/rpms

# Build php56-php
sudo mock -r $MOCK_CONFIG --define "scl php56" --define "scl_vendor remi" --define "rh_layout 1" --rebuild $BUILD_DIR/srpms/php-5.6.40-45.el9.src.rpm
ls -al $MOCK_RESULT_DIR
cp $MOCK_RESULT_DIR/php56-php-5.6.40-45.el9.x86_64.rpm           $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-bcmath-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-cli-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-common-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-dba-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-dbg-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-devel-5.6.40-45.el9.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-embedded-5.6.40-45.el9.x86_64.rpm  $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-enchant-5.6.40-45.el9.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-fpm-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-gd-5.6.40-45.el9.x86_64.rpm        $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-gmp-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-imap-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-interbase-5.6.40-45.el9.x86_64.rpm $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-intl-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-ldap-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-litespeed-5.6.40-45.el9.x86_64.rpm $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mbstring-5.6.40-45.el9.x86_64.rpm  $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mcrypt-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mssql-5.6.40-45.el9.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-mysqlnd-5.6.40-45.el9.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-odbc-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-opcache-5.6.40-45.el9.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pdo-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pgsql-5.6.40-45.el9.x86_64.rpm     $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-process-5.6.40-45.el9.x86_64.rpm   $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-pspell-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-recode-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-snmp-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-soap-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-tidy-5.6.40-45.el9.x86_64.rpm      $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-xml-5.6.40-45.el9.x86_64.rpm       $BUILD_DIR/rpms
cp $MOCK_RESULT_DIR/php56-php-xmlrpc-5.6.40-45.el9.x86_64.rpm    $BUILD_DIR/rpms
createrepo_c --update $BUILD_DIR/rpms

sudo mock -r $MOCK_CONFIG --clean
