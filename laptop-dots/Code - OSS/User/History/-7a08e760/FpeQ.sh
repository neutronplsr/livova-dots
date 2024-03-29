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
  echo "installing $wmInst"
fi



opt1="nvidia"
opt2="code"
opt3="space"
opt4="gaming"
opt5="useful"
opt6="all"

packgelist=""

optArray[0]=" nvidia-dkms "
optArray[1]=" code python python-pipx rust pyenv "
optArray[2]=" stellarium python-astropy31 ds9 "
optArray[3]=" steam lutris protonup-qt qbittorrent-git xpadneo-dkms "
optArray[4]=" obsidian-bin pcloud-drive betterdiscordctl discord openasar-git mullvad-vpn firefox-beta-bin "
#install optional packages, check for dotfiles
for arg in "$@"; do
    case "$arg" in
        "$opt1")
            echo "installing nvidia packages..."
            packgelist+="$optArray[0]"
            ;;
        "$opt2")
            echo "installing code packages..."
            packgelist+="$optArray[1]"
            ;;
        "$opt3")
            echo "installing space packages AND code packages ..."
            packgelist+=optArray[1]
            packgelist+=optArray[2]
            ;;
        "$opt4")
            echo "installing gaming packages ..."
            packgelist+=optArray[3]
            ;;
        "$opt5")
            echo "installing useful packages ..."
            packgelist+=optArray[4]
            ;;
        "$opt6")
            echo "installing all optional packages ..."
            packgelist+=optArray[0]
            packgelist+=optArray[1]
            packgelist+=optArray[2]
            packgelist+=optArray[3]
            packgelist+=optArray[4]
            break
            ;;
        "$wm1" | "$wm2" | "$wm3" | "$wm4" | "$wm5" | "$wm6" | "$dot1" | "$dot2")
            ;;
        *)
            echo "argument not found: $arg moving on..."
            ;;
    esac
done
echo "paru -S --needed --noconfirm $packgelist"




#install dot-files
##if both passed, pretty takes priority

if [ "$prty" == 1 ]; then
  echo "installing recommended dot files"
  elif [ "$livvy" == 1 ]; then
  echo "installing livova dot files"
fi



echo "please reboot for best resulusts" 