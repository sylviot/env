#! /bin/bash

preinstall_arch() {
  if [ ! -s "/etc/pacman.d/mirrorlist" ]; then
    print "> > Configuring mirror list..."
    sudo -rm -f /etc/pacman.d/mirrorlist
    curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&use_mirror_status=on" > /etc/pacman.d/mirrorlist
    sed -i 's/\#.*(Server)/\1/g' /etc/pacman.d/mirrorlist
  fi

  if [ -z "`grep archlinuxfr /etc/pacman.conf`" ]; then
    print "> > Configuring yaourt server..."
    sudo bash -c "echo -e '\n\n[archlinuxfr]\nSigLevel=Never\nServer=http://repo.archlinux.fr/\$arch' >> /etc/pacman.conf"
  fi
}

install_arch () {
  print "> > > Preinstalling $BLUE ARCH LINUX $DEFAULT < < < <"

  preinstall_arch

  print "> > > Installing $BLUE ARCH LINUX $DEFAULT < < < <"

  PACKAGES="xorg-server xorg-server-utils xorg-xinit xorg-twm xorg-xclock xterm xfce4 lightdm "
  PACKAGES+="wget htop git vim gvim zsh bash-completion ctags docker vlc clementine unrar yajl yaourt "
  # PACKAGES+="qemu-kvm qemu virt-manager virt-viewer libvirt-bin "
  PACKAGES+="chromium firefox opera "

  sudo pacman -Sy

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling pacman packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi
  
  PACKAGES="google-chrome lightdm-webkit2-greeter archey3 "

  #yaourt installs
  if [ -n "`(yaourt -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $PACKAGES
  fi

  if [ ! -d "$HOME/env" ]; then
    git clone https://github.com/sylviot/env.git ~/env
  fi

  configure_desktop
  configure_vim
  configure_zsh
  configure_docker
}

configure_desktop() {
  print "Configuring desktop..."

  #Configure lightdm.conf
  sudo sed -i -r 's/^#.(greeter-session.=).*$/\1lightdm-webkit2-greeter/g' /etc/lightdm/lightdm.conf
  sudo systemctl enable lightdm

  #download image backgroud
  #xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /temp/background.jpg
}

configure_docker() {
  print "Configuring docker..."
  #if [-n "`systemctl is-enabled docker | grep disabled`"]; then
  sudo systemctl enable docker
  sudo usermod -aG docker sylviot

  # confirm pulling
  read -p "Download docker images? [y/n] " -r
  if [[ "$REPLY" == "y" ]]; then

    print "Pulling docker images..."
    docker pull php
    docker pull ambientum/php:7.0-nginx
    docker pull phpunit/phpunit
    docker pull postgres
    docker pull redis
    docker pull elixir
    docker pull node

    docker run --name web-cache -d redis
    docker run --name web-db -d postgres
  fi

  print "Configuring docker bin..."
  sudo ln -s ~/env/bin/* /usr/local/bin/
}

configure_vim() {
  print "Configuring vim..."

  if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    print "Configuring Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  fi

  if [ ! -s "$HOME/.vimrc" ]; then
    print "Configuring .vimrc..."
    git clone https://github.com/sylviot/dot.git /tmp/dot
    mv /tmp/dot/.vimrc $HOME/.vimrc
  fi

  print "Install/Update Vundle plugins..."
  vim +VundleInstall +qall &> /dev/null

  if [ -z "`ls $HOME/.local/share/fonts/ | grep Powerline`" ]; then
    print "Installing powerline fonts..."
    git clone https://github.com/powerline/fonts.git /tmp/powerline-fonts &&
    cd /tmp/powerline-fonts &&
    ./install.sh
  fi
}

configure_zsh() {
  if [ ! -z "`echo $SHELL | grep zsh`" ]; then
    print "Configuring zsh..."
    sudo chsh -s $(which zsh)
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print "Configuring oh-my-zsh..."
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
  fi
}

print () {
  DEFAULT='\033[0;31m'
  NC='\033[0m'
  echo -e "$DEFAULT > $1$NC"
}

install_arch
