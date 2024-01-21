### gerekli paketler kuruldu
apt update
apt-get install git dwarves linux-image-generic libelf-dev build-essential ccache debhelper clang \ 
lld wget coreutils libncurses-dev bison flex libssl-dev unzip xz-utils -y 
apt-get install kernel-package ncurses-dev bzip2 module-init-tools initrd-tools procps \ 
libncurses5-dev gcc make git exuberant-ctags bc libssl-dev rsync rsync-dev -y

### kernel tarball indirildi ve açıldı
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.10.tar.xz
tar -xvf linux-6.6.10.tar.xz
cd linux-6.6.10

### degiskenler ayarlanıyor
VERSION="6.6.10"
pkgdir="build"
mkdir -p $pkgdir
modulesdir=${pkgdir}/lib/modules/${VERSION}
builddir="${pkgdir}/lib/modules/${VERSION}/build"
arch=x86

### config indirilir archlinux ayarları
wget -O .config https://gitlab.archlinux.org/archlinux/packaging/packages/linux/-/raw/main/config?ref_type=heads&inline=false

### kernel derleme yapılır
make bzImage

### modul derleme yapılır
make modules 

### derlenmiş kernel kopyalanır
mkdir -p /output/kernel
cp  arch/x86/boot/bzImage /output/kernel/vmlinuz


### derlenmiş modüller kopyalanır
mkdir -p /output/modul
mkdir -p "$modulesdir"
make INSTALL_MOD_PATH="$pkgdir" INSTALL_MOD_STRIP=1 modules_install -j$(nproc)
rm "$modulesdir"/{source,build} || true
depmod --all --verbose --basedir="$pkgdir" "${VERSION}" || true
# install build directories
tar -cf modul.tar "$modulesdir"
xz modul.tar
cp  modul.tar.xz /output/modul

### install libc headers
mkdir -p /output/header
mkdir -p "$pkgdir/usr/include/linux"
cp -v -t "$pkgdir/usr/include/" -a include/linux/
cp -v -t "$pkgdir/usr/" -a tools/include
make headers_install INSTALL_HDR_PATH="$pkgdir/usr"

tar -cf header.tar "$pkgdir/usr/"
cp  header.tar /output/header

