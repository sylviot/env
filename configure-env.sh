#! /bin/bash

install_arch () {
  print "%RED%Installing ARCH LINUX%NC% - sylviot"

  PACKAGES="zsh git yajl vlc wget htop unrar yaourt "
  PACKAGES+="chromium firefox opera "

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi 
}

preinstall_arch() {
  print "Preinstalling ARCH LINUX"
  sudo bash -c "echo -e '[archlinuxfr]\nSigLevel=Never\nServer=http://repo.archlinux.fr/\$arch' >> /etc/pacman.conf"
}

postinstall_arch() {
  docker pull php
  docker pull postgres
  docker pull redis
  docker pull elixir
}

configure_docker() {
  print "Configuring docker..."
  sudo systemctl enable docker
  sudo usermod -aG docker sylviot
}

configure_vim() {
  print "Configuring vim..."

}

configure_powerline() {
  print "Configuring powerline..."
  if [ -z "`ls $HOME/share/fonts/ | grep Powerline`" ]; then
    print "Installing powerline fonts..."
    git clone https://github.com/powerline/fonts.git /tmp/powerline-fonts &&
    cd /tmp/powerline-fonts &&
    ./install.sh
  fi
}

configure_yaourt() {
  print "Configuring yaourt..."
}

configure_zsh() {
  sudo chsh -s $(which zsh)
}

print () {
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e "> $1" | sed -e "s/%\w*%//g"
  #echo "> $1" | sed  "s/%(\w)%/\1/g"
}

#configure_yaourt
#configure_docker
#configure_zsh
#configure_powerline
#preinstall_arch
install_arch
