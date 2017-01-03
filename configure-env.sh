#! /bin/bash

install_arch () {
  print "Installing ARCH LINUX - sylviot"

  PACKAGES="zsh git yajl vlc wget htop unrar yaourt "
  PACKAGES+="chromium firefox opera "

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi 
}

preinstall_arch() {
  print "Preinstalling ARCH LINUX"

  if [ -z "`grep archlinuxfr /etc/pacman.conf`" ]; then
    print "> > Configuring yaourt server..."
    sudo bash -c "echo -e '[archlinuxfr]\nSigLevel=Never\nServer=http://repo.archlinux.fr/\$arch' >> /etc/pacman.conf"
  fi
}

postinstall_arch() {
  print "Postinstalling ARCH LINUX"

  #docker pull php
  #docker pull postgres
  #docker pull redis
  #docker pull elixir
}

configure_docker() {
  print "Configuring docker..."
  sudo systemctl enable docker
  sudo usermod -aG docker sylviot
}

configure_vim() {
  print "Configuring vim..."

  if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    print "Configuring vundle..."
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  fi
  print "Install vundle plugins..."
  vim +VundleInstall +qall

  if [ -z "`ls $HOME/share/fonts/ | grep Powerline`" ]; then
    print "Installing powerline fonts..."
    git clone https://github.com/powerline/fonts.git /tmp/powerline-fonts &&
    cd /tmp/powerline-fonts &&
    ./install.sh
  fi
}

configure_zsh() {
  sudo chsh -s $(which zsh)
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print "Configuring oh-my-zsh..."
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
  fi
}

print () {
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e "$RED> $1$NC" | sed -e "s/%\w*%//g"
  #echo "> $1" | sed  "s/%(\w)%/\1/g"
}

if [[ "$1" == "postinstall" ]]; then
  postinstall_arch
else
  install_arch
fi
