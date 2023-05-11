start_time=$(date +%s)

unset urls
unset files
unset log_files

export ROOTDIR="${PWD}"
export BIN_NAME="ncspot"
export SD_DIR="App"
export FIN_BIN_DIR="/mnt/SDCARD/$SD_DIR/$BIN_NAME"
export CROSS_COMPILE="arm-linux-gnueabihf"
export AR=${CROSS_COMPILE}-ar
export AS=${CROSS_COMPILE}-as
export LD=${CROSS_COMPILE}-ld
export RANLIB=${CROSS_COMPILE}-ranlib
export CC=${CROSS_COMPILE}-gcc
export NM=${CROSS_COMPILE}-nm
export HOST=arm-linux-gnueabihf
export BUILD=x86_64-linux-gnu
export CFLAGS="-Wno-undef -Os -marm -mtune=cortex-a7 -mfpu=neon-vfpv4  -march=armv7ve+simd -mfloat-abi=hard -ffunction-sections -fdata-sections"
export CXXFLAGS="-s -O3 -fPIC -pthread"
export PATH="$PATH:$FIN_BIN_DIR/bin/"

#Copy these files to lib to stop some test failures on makes, not really needed in most cases - also stops pkgconfig working - could be ldflags
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/ld-linux-armhf.so.3 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libpthread.so.0 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libc.so.6 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libm.so.6 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libcrypt.so.1 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libdl.so.2 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libutil.so.1 /lib/
cp /opt/miyoomini-toolchain/arm-linux-gnueabihf/libc/lib/libstdc++.so.6 /lib/

export LOGFILE=./logs/buildtracker.txt # set a full log file
mkdir $ROOTDIR/logs

#Script header section

echo -e "\033[32m⠀⠀⠀⠀⠀⠀⠀            ⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣶⣶⣶⣶⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀"
echo -e "⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀"
echo -e "⠀⢀⣾⣿⡿⠿⠛⠛⠛⠉⠉⠉⠉⠛⠛⠛⠿⠿⣿⣿⣿⣿⣿⣷⡀⠀"
echo -e "⠀⣾⣿⣿⣇⠀⣀⣀⣠⣤⣤⣤⣤⣤⣀⣀⠀⠀⠀⠈⠙⠻⣿⣿⣷⠀ "
echo -e "⢠⣿⣿⣿⣿⡿⠿⠟⠛⠛⠛⠛⠛⠛⠻⠿⢿⣿⣶⣤⣀⣠⣿⣿⣿⡄ 	\033[0mMiyoo Mini+ ncspot(Spotify) compiler\033[32m"
echo -e "⢸⣿⣿⣿⣿⣇⣀⣀⣤⣤⣤⣤⣤⣄⣀⣀⠀⠀⠉⠛⢿⣿⣿⣿⣿⡇ 	\033[0mXK9274\033[32m"
echo -e "⠘⣿⣿⣿⣿⣿⠿⠿⠛⠛⠛⠛⠛⠛⠿⠿⣿⣶⣦⣤⣾⣿⣿⣿⣿⠃"
echo -e "⠀⢿⣿⣿⣿⣿⣤⣤⣤⣤⣶⣶⣦⣤⣤⣄⡀⠈⠙⣿⣿⣿⣿⣿⡿⠀"
echo -e "⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[31m⣿\033[0m\033[32m⣿⣿⣿⣿⣷⣾⣿⣿⣿⣿⡿⠁⠀"
echo -e "⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿\033[31m⣿⣿⣿\033[0m\033[32m⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿\033[31m⣿\033[0m\033[32m⣿⣿⣿⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀"
echo -e "⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠿⠿⠿⠿⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀\033[0m"

echo -e "\n" 			
echo -e "-Building \033[32m"$BIN_NAME"\033[0m for: \033[32m"$CROSS_COMPILE "\033[0m"

echo -e "-Building with a prefix of \033[32m$FIN_BIN_DIR\033[0m"	

echo -e "-The build will use \033[32m"$(( $(nproc) - 2 ))"\033[0m cpu threads of the max: \033[32m"`nproc`"\033[0m"
echo  "-The script will output a list of failed makes at the end.."			
echo -e "\n"
echo "-This will compile ncspot with the alsa backend"
echo -e "\n"
echo "-Warning: If you're building this on WSL2 it will be incredibly slow and likely take over a day to build, create a docker image in your \\wsl$\distro\home\user\ location and run from there."
echo "For reference it takes around 10 mins to download & build everything on a 1gbps circuit with an I9-11900k."
echo -e "\n"
echo -e "-Starting shortly - a full logfile with be in: \033[32m"$LOGFILE "\033[0m"
echo -e "\n"

for i in {9..1}; do
    echo -ne "Starting in $i\r"
    sleep 1
done

echo -e "\n\n\n"

while true; do # check if a build has already been completed, it may be best to do a fresh build if you've changed anything
    if [ -d "$ROOTDIR/$BIN_NAME" ]; then
        read -p "A previously completed build of $BIN_NAME already exists. Do you want to remove this & build fresh? (y/n)" rebuildq
        case "$rebuildq" in 
            y|Y ) 
                echo "Deleting previous build..."
                rm -rf $ROOTDIR/$BIN_NAME
                rm -rf $FIN_BIN_DIR
                rm -rf */ 
				rm -f wget-log*
                mkdir $ROOTDIR/logs
                mkdir -p $FIN_BIN_DIR
                break
                ;;
            n|N ) 
                echo "Rebuilding over the top of the last build..."
                break
                ;;
            * ) 
                echo "Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    else
        echo -e "\033[32mNo previous build detected, starting...\033[0m"
        break
    fi
done

cd ~/workspace/

#Start logging and begin
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> >(tee -a "$LOGFILE") 2>&1					

#Download everything, but check if it already exists.

urls=(
	"https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
	"https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz"
	"https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz"
	"https://ftp.gnu.org/gnu/m4/m4-latest.tar.xz"
	"https://github.com/openssl/openssl/releases/download/openssl-3.1.0/openssl-3.1.0.tar.gz"
	"https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz"
	"https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz"
	"https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.8.tar.bz2"
	"https://www.alsa-project.org/files/files/pub/utils/alsa-utils-1.2.8.tar.bz2"
	"https://github.com/pop-os/libasound2/archive/refs/tags/v1.2.7.tar.gz"
)

# Parallel download and wait until finished.
pids=()
for url in "${urls[@]}"; do
  file_name=$(basename "$url")
  if [ ! -f "$file_name" ]; then
    echo "Downloading $file_name..."
    wget -q "$url" &
    pids+=($!)
  else
    echo "$file_name already exists, skipping download..."
  fi
done

for pid in "${pids[@]}"; do
  wait $pid
done

echo -e "\n\n\033[32mAll downloads finished, now building..\033[0m\n\n"

# Check all files have downloaded before trying to build

files=(
    "alsa-lib-1.2.8.tar.bz2"
	"alsa-utils-1.2.8.tar.bz2"
	"autoconf-latest.tar.gz"
	"automake-1.16.5.tar.xz"
	"libasound2-1.2.7.tar.gz"
	"libtool-2.4.7.tar.xz"
	"m4-latest.tar.xz"
	"ncurses-6.4.tar.gz"
	"openssl-3.1.0.tar.gz"
	"pkg-config-0.29.2.tar.gz"
)

missing_files=()
for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    echo -e "\033[32mAll files exist...\033[0m\n\n"
    sleep 1
else #check if any of the downloads failed, if they did try to redownload, if they still fail prompt for a new url with the filename..
    echo "Missing files: ${missing_files[@]}"
    echo "Trying to download again...."
    for file in "${missing_files[@]}"; do
        for url in "${urls[@]}"; do
            if [[ "$url" == *"$file"* ]]; then
                wget -q "$url"
                if [ $? -ne 0 ]; then
                    echo "Error downloading $file from $url"
                    read -p "Enter a new WORKING URL for $file: " new_url
                    wget -q "$new_url"
                fi
            fi
        done
    done
fi

# Start compiling..

## pkg config 
echo -e "-Compiling \033[32mpkconfig\033[0m"
tar -xf pkg-config-0.29.2.tar.gz &
wait $!
cd pkg-config-0.29.2
./configure CC=$CC AR=$AR RANLIB=$RANLIB LD=$LD --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR --disable-shared --with-internal-glib glib_cv_stack_grows=no glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/pkgconfigbuildlog.txt 2>&1  &
wait $!
export PKG_CONFIG_PATH="$FIN_BIN_DIR/lib/pkgconfig"
export PKG_CONFIG="$FIN_BIN_DIR/bin/pkg-config"
cd ..

# m4
echo -e "-Compiling \033[32mm4\033[0m"
tar -xf m4-latest.tar.xz &
wait $!
cd m4-1.4.19
./configure CC=$CC LD=$LD --host=$HOST --build=$BUILD --target=$TARGET  --prefix=$FIN_BIN_DIR &
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/m4-1.4.19.txt 2>&1 &
wait $!
cd ..

# Autoconf
echo -e "-Compiling \033[32mautoconf\033[0m"
tar -xf autoconf-latest.tar.gz &
wait $!
cd autoconf-2.71/
./configure CC=$CC --host=$HOST --build=$BUILD --prefix=$FIN_BIN_DIR M4=$FIN_BIN_DIR/bin/m4 &
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/autoconf-2.71.txt 2>&1 &
cd ..

export M4=$FIN_BIN_DIR/bin/m4

#Cross Compile Libtool
echo -e "-Compiling \033[32mlibtool\033[0m"
tar -xf libtool-2.4.7.tar.xz &
wait $!
cd libtool-2.4.7
./configure CC=$CC --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR M4=$FIN_BIN_DIR/bin/m4 &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/libtool-2.4.7.txt 2>&1 &
wait $!
$FIN_BIN_DIR/bin/libtool --finish $FIN_BIN_DIR/lib
cd ..

# Cross compile ncursesW
echo -e "-Compiling \033[32mncurses\033[0m"
tar -xf ncurses-6.4.tar.gz &
wait $!
cd ncurses-6.4
./configure CC=$CC --build=$BUILD --host=$HOST --prefix=$FIN_BIN_DIR --with-fallbacks=vt100,vt102 --disable-stripping --with-shared --with-termlib --with-ticlib --enable-widec --enable-pc-files
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/ncurses-6.4.txt 2>&1 &
wait $!
cd ..

# Cross compile ncurses
echo -e "-Compiling \033[32mncurses\033[0m"
tar -xf ncurses-6.4.tar.gz &
wait $!
cd ncurses-6.4
./configure CC=$CC --build=$BUILD --host=$HOST --prefix=$FIN_BIN_DIR --with-fallbacks=vt100,vt102 --disable-stripping --with-shared --with-termlib --with-ticlib 
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/ncurses-6.4.txt 2>&1 &
wait $!
cd ..

# Automake
echo -e "-Compiling \033[32mautomake\033[0m"
tar -xf automake-1.16.5.tar.xz &
wait $!
cd automake-1.16.5
./configure CC=$CC --host=$HOST --build=$BUILD --prefix=$FIN_BIN_DIR AUTOCONF=$FIN_BIN_DIR/bin/autoconf &
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/automake-1.16.5.txt 2>&1 &
wait $!
cd ..

#Cross Compile Libtool
echo -e "-Compiling \033[32mlibtool\033[0m"
tar -xf libtool-2.4.7.tar.xz &
wait $!
cd libtool-2.4.7
./configure CC=$CC --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR M4=$FIN_BIN_DIR/bin/m4 &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/libtool-2.4.7.txt 2>&1 &
wait $!
$FIN_BIN_DIR/bin/libtool --finish $FIN_BIN_DIR/lib
cd ..

#Cross compile OpenSSL 
echo -e "-Compiling \033[32mopenssl\033[0m"
export CROSS_COMPILE="" #  set this or it gets confused as $CROSS_COMPILE appears on the cc lines already
tar -xf openssl-3.1.0.tar.gz
cd openssl-3.1.0
./Configure --prefix=$FIN_BIN_DIR --openssldir=$FIN_BIN_DIR linux-generic32 shared -DL_ENDIAN PROCESSOR=ARM &
wait $!
make clean && make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) > ../logs/openssl-3.1.0.txt &
wait $!
cd ..
export CROSS_COMPILE="arm-linux-gnueabihf" #  set back

#Cross compile libasound
echo -e "-Compiling \033[32mlibasound\033[0m"
tar -xf v1.2.7.tar.gz
cd libasound2-1.2.7
wait $!
$FIN_BIN_DIR/bin/libtoolize
$FIN_BIN_DIR/bin/aclocal
$FIN_BIN_DIR/bin/autoheader
$FIN_BIN_DIR/bin/automake --add-missing
$FIN_BIN_DIR/bin/autoconf
$FIN_BIN_DIR/bin/autoupdate --force
./configure CC=$CC --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR --disable-dependency-tracking &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) &&  > ../logs/libasound2-1.2.7.txt 2>&1 &
wait $!
cd ~/workspace/

#Cross compile alsa
echo -e "-Compiling \033[32malsa-lib\033[0m"
tar -xf alsa-lib-1.2.8.tar.bz2
cd alsa-lib-1.2.8
./configure CC=$CC --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR --sysconfdir=$FIN_BIN_DIR --exec-prefix=$FIN_BIN_DIR --localstatedir=$FIN_BIN_DIR --datarootdir=$FIN_BIN_DIR &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) &&  > ../logs/alsa-lib-1.2.8.txt 2>&1 &
wait $!
cd ..

export CPPFLAGS="-I$FIN_BIN_DIR/include"
export LDFLAGS="-L$FIN_BIN_DIR/lib/ -lasound -lpanel -lncurses -ltinfo"

#Cross compile alsautils
echo -e "-Compiling \033[32malsa-utils\033[0m"
tar -xf alsa-utils-1.2.8.tar.bz2
cd alsa-utils-1.2.8
CFLAGS="$CFLAGS -I$FIN_BIN_DIR/include/ncurses/" 
./configure CC=$CC --host=$HOST --build=$BUILD --target=$TARGET --prefix=$FIN_BIN_DIR --disable-xmlto --disable-nls --with-curses=ncurses PKG_CONFIG_LIBDIR=$FIN_BIN_DIR/lib/pkgconfig &
wait $!
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) &&  > ../logs/alsa-utils-1.2.8.txt 2>&1 &
wait $!
cd ..

echo -e "-Compiling \033[32mrust\033[0m"
# set some rust/cargo vars
export CARGO_BUILD_TARGET=arm-unknown-linux-gnueabihf
export CARGO_TARGET_ARM_UNKNOWN_LINUX_GNUEABIHF_LINKER=/opt/miyoomini-toolchain/usr/bin/arm-linux-gnueabihf-gcc
export CARGO_INSTALL_ROOT=$FIN_BIN_DIR
export CARGO_HOME="$FIN_BIN_DIR/cargo"
export RUSTFLAGS="-L $FIN_BIN_DIR/lib -C link-arg=$FIN_BIN_DIR/include/ncurses/ncurses_dll.h"
# Install Rust with target set for the miyoo
wget -qO - https://sh.rustup.rs | bash -s -- -y --target arm-unknown-linux-gnueabihf

# Rust flags - set some rust flags

#Install ncspot #
$FIN_BIN_DIR/cargo/bin/cargo install ncspot --no-default-features --features cursive/termion-backend --locked

#Main compile done if you get a success message, if not check the below output in the logfile
#Check if the logfiles appear, these are only created at the install stage which rarely fails - could be checked better but this works:

echo -e "\n\n\n"

log_files=(				   					   
	"alsa-lib-1.2.8.txt"
	"alsa-utils-1.2.8.txt"
	"autoconf-2.71.txt"
	"automake-1.16.5.txt"
	"buildtracker.txt"
	"libasound2-1.2.7.txt"		  
	"libtool-2.4.7.txt"
	"m4-1.4.19.txt"
	"ncurses-6.4.txt"
	"openssl-3.1.0.txt"
	"pkgconfigbuildlog.txt"
)

for log_file in "${log_files[@]}"
do
  if [ ! -f "logs/$log_file" ]; then
    echo "$log_file FAILED"
	failed_logs="$failed_logs $log_file"
	else
	echo "$log_file built OK"
  fi
done

# Prep the ncspot folder to quickly be copied out.
# Cleanup
# Edit some files
# All this is done if the ncspot bin was installed to the bin folder.

if [ -f "$FIN_BIN_DIR/bin/$BIN_NAME" ]; then # Check if the bin file for BINNAME exists. $FIN_BIN_DIR changes to $ROOTDIR here as it gets copied to the workspace.
	echo -e "\n\n"
	echo "Preparing export folder"
	echo -e "\n\n"
	echo "Moving built files to workspace area"
	mkdir -v $ROOTDIR/$BIN_NAME
	cp -r "$FIN_BIN_DIR/"* "$ROOTDIR/$BIN_NAME" &
	wait $!
	
	# Fix some libraries
	rm  $ROOTDIR/$BIN_NAME/lib/libpanel.so.6
	cp  $ROOTDIR/$BIN_NAME/lib/libpanel.so.6.4 $ROOTDIR/$BIN_NAME/lib/libpanel.so.6
	rm  $ROOTDIR/$BIN_NAME/lib/libncurses.so.6
	cp  $ROOTDIR/$BIN_NAME/lib/libpanel.so.6.4 $ROOTDIR/$BIN_NAME/lib/libncurses.so.6
	rm  $ROOTDIR/$BIN_NAME/lib/libtinfo.so.6
	cp  $ROOTDIR/$BIN_NAME/lib/libtinfo.so.6.4 $ROOTDIR/$BIN_NAME/lib/libtinfo.so.6
	rm  $ROOTDIR/$BIN_NAME/lib/libform.so.6
	cp  $ROOTDIR/$BIN_NAME/lib/libform.so.6.4 $ROOTDIR/$BIN_NAME/lib/libform.so.6
	rm  $ROOTDIR/$BIN_NAME/lib/libmenu.so.6
	cp  $ROOTDIR/$BIN_NAME/lib/libmenu.so.6.4 $ROOTDIR/$BIN_NAME/lib/libmenu.so.6
	rm  $ROOTDIR/$BIN_NAME/lib/libasound.so.2
	cp  $ROOTDIR/$BIN_NAME/lib/libasound.so.2.0.0 $ROOTDIR/$BIN_NAME/lib/libasound.so.2

	
	# remove some excess fat from the end product dir
	rm -rf $BIN_NAME/aclocal/
	rm -rf $BIN_NAME/docs/
	rm -rf $BIN_NAME/doc/
	rm -rf $BIN_NAME/certs/
	rm -rf $BIN_NAME/include/
	rm -rf $BIN_NAME/bin/{gio,glib-compile-resources,gdbus,gsettings,gapplication,gresource,pytho,gio-querymodules,gobject-query,glib-compile-schemas}
	rm -rf $BIN_NAME/share/{doc,autoconf,man,gdb,glib-2.0,automake-1.16,aclocal-1.16,aclocal,bash-completion,gtk-doc,glib2-0,info,libtool,pkgconfig,readline,tabset,terminfo,util-macros,vala,xcb,zcb,zsh}
	rm -rf $BIN_NAME/lib/{python3.7/test,pkgconfig,cmake}
	rm -rf $BIN_NAME/xml
	rm -rf $BIN_NAME/misc
	rm -rf $BIN_NAME/GConf
	rm -rf $BIN_NAME/man
	rm -rf $BIN_NAME/cargo

echo -e "\n\n"
fi 
end_time=$(date +%s)
duration=$((end_time - start_time))

# checks if the final product dir was moved to the /workspace/ folder, indicating it built OK
if [ -z "$failed_logs" ]; then
  if [ -d "$ROOTDIR/$BIN_NAME" ]; then
    echo -e "\033[32mComplete - your finished build is in /workspace/$BIN_NAME, this will contain all build products... "
	echo -e "Build duration: $duration seconds\033[0m"
  else
    echo -e "Build failed, check ~/workspace/logs/buildtracker.txt for more info"
  fi
else
  if [ -d "$ROOTDIR/$BIN_NAME" ]; then
    echo -e "\033[32mComplete - your finished build is in /workspace/$BIN_NAME, this will contain all build products... "
	echo "Build duration: $duration seconds"
    echo -e "These packages did not complete\033[31m$failed_logs\033[32m but it has not affected the $BIN_NAME bin being built\033[0m."
  else
    echo -e "Build failed, these packages did not complete \033[31m$failed_logs\033[0m check ~/workspace/logs/buildtracker.txt for more info"
  fi
fi	