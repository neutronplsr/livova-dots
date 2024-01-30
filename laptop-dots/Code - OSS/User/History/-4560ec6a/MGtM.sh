#! /usr/bin/bash

# some assumptions:
#   you have: installed arch linux 
#   you have: linux linux-firmware linux-firmware-whence base base-devel networkmanager git
#   you have: some network connection
#   you have: sudo privleges


#inputs in the form <desktop-env> <custom-config (cattpucin)>
#make sure user gave enough arguments
if [ -z "$1" ]
  then
    echo "not enough arguments provided, please format as  \"livova-installer.sh <desktop-env> <custom-config>\" (this last is optional, has default value of null) exiting..."
    exit 0   
fi

#setup things
echo "running setup..."
mkdir ~/repos/
sudo pacman -Syy  --noconfirm 

#install aur helper
echo "installing paru..."
git clone https://aur.archlinux.org/paru.git ~/repos/
cd ~/repos/paru 
makepkg -si --noconfirm 
cd ~

#install base case programs
echo "installing base programs"
paru -S --needed --noconfirm  os-prober  wget  linux-tools-meta dust reflector tlp bzip2 gzip lrzip lz4 lzip lzop xz zstd p7zip zip unzip unrar unarchiver xarchiver  less blueman pipewire pipewire-pulse pipewire-alsa firefox linux-headers

sudo systemctl start bluetooth
sudo systemctl enable pipewire.service

#! /usr/bin/bash
##check user didnt mess up and provide too many WM/DE
wm1="gnome"
wm2="qtile"
wm3="gnome-way"
wm4="qtile-way"
wm5="hyprland"
wm6="hyprland-nvidia"

dot1="--pretty"
dot2="--livovaStyle"

wm_check=0
wmInst=""


prty=0
livvy=0

argChecker() {
  found=0 
  for args in "$@"; do
    case "$args" in 
            "$wm1" | "$wm2" | "$wm3" | "$wm4" | "$wm5" | "$wm6")
                ((found++))
                wmInst="$args"
                ;;
            "$dot1")
              prty=1
              ;;
            "$dot2")
              livvy=1
              ;; 
        esac
    done

    if [ "$found" -gt 1 ]; then
      echo "too many WE/DE arguments passed. please only provide one. the script will finish as if you passed no arugment of this kind."
      wm_check=1
    fi
    if [ "$livvy" == 1 ]  && [ "$prty" == 1 ]; then
      echo "too many dot file arguments passed. please only provide one in the future. the script will use recommended files."
    fi
}

argChecker "$@"

#install desired WM/DE
if [ "$wm_check" == 0 ]; then
    case "$wmInst" in 
            "$wm1")
              echo "installing gnome (xorg)"
              paru -S --needed --noconfirm xorg xorg-server
              paru -S --needed --noconfirm gnome gnome-tweaks gnome-terminal gnome-bluetooth 
              
              sudo systemctl start gdm.service
              ;;
            "$wm2")
              echo "installing qtile (xorg)"
              paru -S --needed --noconfirm xorg xorg-server lightdm-gtk-greeter
              paru -S --needed -noconfirm qtile qtile-extras


              sudo systemctl enable lightdm
              ;;
            "$wm3")
              echo "installing gnome (wayland)"
              paru -S --needed --noconfirm wayland xorg-xwayland xorg-xlsclients glfw-wayland wlroots python-pywlroots 
              paru -S --needed --noconfirm gnome gnome-tweaks gnome-terminal gnome-bluetooth 
              
              sudo systemctl start gdm.service
              ;;
            "$wm4")
              echo "installing qtile (wayland)"
              paru -S --needed --noconfirm wayland xorg-xwayland xorg-xlsclients glfw-wayland wlroots python-pywlroots 
              paru -S --needed --noconfirm qtile qtile-extras
              paru -S --needed --noconfirm sddm
              
              sudo systemctl enable sddm
              ;;
            "$wm5")
              echo "installing hyprland (non nvidia)"
              paru -S --needed --noconfirm gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus kitty wlroots python-pywlroots 
              paru -S --needed --noconfirm hyprland-git 
              paru -S --needed --noconfirm sddm
              paru -S --needed --noconfirm wired wireplumber xdg-desktop-portal-hyprland polkit-kde-agent wofi
            
              sudo systemctl enable sddm
              ;;
            "$wm6")
              echo "installing hyprland (nvidia)"
              paru -S --needed --noconfirm gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus kitty wlroots python-pywlroots 
              paru -S --needed --noconfirm hyprland-git 
              paru -S --needed --noconfirm wired wireplumber xdg-desktop-portal-hyprland polkit-kde-agent wofi

              #nvidia weirdness
              paru -S --needed --noconfirm nvidia-dkms linux-headers qt5-wayland qt6-wayland qt5ct qt6ct libva libva-nvidia-driver-git

              sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1 noapic"/' /etc/default/grub
              sudo grub-mkconfig -o /boot/grub/grub.cfg

              sudo sed -i '/^MODULES=/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
              sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img

              echo "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf > /dev/null
              
              mkdir .config/hypr
              cp repos/Hyprland/example/hyprland.conf .config/hypr/hyprland.conf
              #micro config.hypr, add:
                #env = LIBVA_DRIVER_NAME,nvidia
                #env = XDG_SESSION_TYPE,wayland
                #env = GBM_BACKEND,nvidia-drm
                #env = __GLX_VENDOR_LIBRARY_NAME,nvidia
                #env = WLR_NO_HARDWARE_CURSORS,1
              paru -S --needed --noconfirm sddm
              sudo systemctl enable sddm

              ;;
            
        esac
fi



opt1="nvidia"
opt2="code"
opt3="space"
opt4="gaming"
opt5="useful"
opt6="all"

packgelist=""

pkg1=" nvidia-dkms "
pkg2=" code pyenv python python-pipx rust  "
pkg3=" ds9 python-astropy31 stellarium "
pkg4=" lutris protonup-qt qbittorrent-git steam xpadneo-dkms "
pkg5=" betterdiscordctl discord firefox-beta-bin mullvad-vpn obsidian-bin openasar-git pcloud-drive "
#install optional packages, check for dotfiles
for arg in "$@"; do
    case "$arg" in
        "$opt1")
            echo "installing nvidia packages..."
            packgelist+="$pkg1"
            ;;
        "$opt2")
            echo "installing code packages..."
            packgelist+="$pkg2"
            ;;
        "$opt3")
            echo "installing space packages AND code packages ..."
            packgelist+="$pkg2"
            packgelist+="$pkg3"
            ;;
        "$opt4")
            echo "installing gaming packages ..."
            packgelist+="$pkg4"
            ;;
        "$opt5")
            echo "installing useful packages ..."
            packgelist+="$pkg5"
            ;;
        "$opt6")
            echo "installing all optional packages ..."
            packgelist+="$pkg1"
            packgelist+="$pkg2"
            packgelist+="$pkg3"
            packgelist+="$pkg4"
            packgelist+="$pkg5"
            break
            ;;
        "$wm1" | "$wm2" | "$wm3" | "$wm4" | "$wm5" | "$wm6" | "$dot1" | "$dot2")
            ;;
        *)
            echo "argument not found: $arg moving on..."
            ;;
    esac
done
eval "paru -S --needed --noconfirm $packgelist"

#install dot-files
##if both passed, pretty takes priority

if [ "$prty" == 1 ]; then
  echo "installing recommended dot files"
  elif [ "$livvy" == 1 ]; then
  echo "installing livova dot files"
fi



echo "please reboot for best resulusts" 