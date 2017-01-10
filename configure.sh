#! /bin/bash

install_arch () {
  print "> > > Preinstalling $BLUE ARCH LINUX $DEFAULT < < < <"

  preinstall_arch

  print "> > > Installing $BLUE ARCH LINUX $DEFAULT < < < <"

  PACKAGES="zsh git vim docker vlc clementine wget htop unrar yajl yaourt "
  # PACKAGES+="qemu-kvm qemu virt-manager virt-viewer libvirt-bin " 
  # test it...
  PACKAGES+="chromium firefox opera "

  sudo pacman -Sy

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling pacman packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi
  
  PACKAGES="chrome "

  #yaourt installs
  if [ -n "`(yaourt -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
  fi

  configure_desktop
  configure_vim
  configure_zsh
  configure_docker
}

preinstall_arch() {
  if [ -z "`grep archlinuxfr /etc/pacman.conf`" ]; then
    print "> > Configuring yaourt server..."
    sudo bash -c "echo -e '\n\n[archlinuxfr]\nSigLevel=Never\nServer=http://repo.archlinux.fr/\$arch' >> /etc/pacman.conf"
  fi
}

configure_desktop() {
  print "Configuring desktop..."

  #download image backgroud
  #xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-time -s /temp/background.jpg
}

configure_docker() {
  print "Configuring docker..."
  sudo systemctl enable docker
  sudo usermod -aG docker sylviot

  # confirm pulling
  
  print "Pulling docker images..."
  # docker pull php
  # docker pull ambientum/php:7.0-nginx
  # docker pull phpunit/phpunit
  # docker pull postgres
  # docker pull redis
  # docker pull elixir
  # docker pull node

  # docker run --name web-cache -d redis
  # docker run --name web-db -d postgres
  # sudo bash -c "echo -e '#! /bin/bash \n docker run --name web --link web-cache --link web-db --ip 172.17.0.100 -v $PWD:/var/www/app ambientum/php:7.0-nginx' >> /usr/local/bin/docker-laravel"
  # sudo chmod +x "/usr/local/bin/docker-laravel"
  # sudo chmod +x "/usr/local/bin/docker-phpunit"  
}

configure_vim() {
  print "Configuring vim..."

  if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    print "Configuring vundle..."
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  fi

  if [ ! -s "$HOME/.vimrc" ]; then
    print "Configuring .vimrc..."
    git clone https://github.com/sylviot/dot.git /tmp/dot
    mv /tmp/dot/.vimrc $HOME/.vimrc
  fi

  print "Install vundle plugins..."
  vim +VundleInstall +qall

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
  BLUE='\033[0;32m'
  NC='\033[0m'
  echo -e "$DEFAULT > $1$NC" | sed -e "s/%\w*%//g"
}

install_arch
