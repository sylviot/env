#!/bin/bash

print () {
  DEFAULT='\033[0;31m'
  NC='\033[0m'
  echo -e "$DEFAULT > $1$NC"
}

with_pacman() {
  print "> > > INSTALL WITH pacman ($@) < < <"

  if [ -n "`(pacman -Qk $@ 2>&1) | grep was\ not\ found`" ]; then
    sudo pacman -Sq --needed --noconfirm $@
  fi
}

with_yaourt() {
  print "> > > INSTALL WITH Yaourt < < <"
  print "> > > ($1) < < <"

  if [ -n "`(yaourt -Qk $1 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $1
  fi
}


update() {
  print "> > > UPDATE Manjaro sylviot < < <"

  sudo pacman -Suy --noconfirm
  install_yaourt

  PACKAGES="wget htop git vim zsh bash-completion unrar "
  PACKAGES+="docker code"

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling pacman packages ($PACKAGES)..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi

  PACKAGES="google-chrome lightdm-webkit2-greeter lightdm-webkit-theme-litarvan"

  if [ -n "`(yaourt -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $PACKAGES
  fi

  print "> > > FINISH UPDATE < < <"
}

install() {
  yaourt

  desktop
  development
  vim
}


# Functions #
run() {
  $1 $2
}

desktop() {
  with_yaourt "lightdm-webkit2-greeter lightdm-webkit-theme-litarvan"

  print "> Configure lightdm"
  sudo sed -i -r -e 's/(greeter-session=).*$/\1lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
  sudo sed -i -r -e 's/^(webkit_theme.*=).*$/\1 litarvan/' /etc/lightdm/lightdm-webkit2-greeter.conf
  sudo systemctl enable lightdm
}

development() {
  with_pacman "wget htop git vim zsh bash-completion docker unrar"

  print "> Configuring docker..."
  if [ -n "`(systemctl is-enabled docker) | grep disabled`"]; then
    print "> Docker systemctl enable"
    sudo systemctl enable docker
    sudo usermod -aG docker sylviot
  fi

  print "Configuring docker bin..."
  
  sudo ln -s ~/env/bin/* /usr/local/bin/
}

vim() {
  print "Configuring vim..."

  if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    print "Configuring Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  fi

  if [ ! -s "$HOME/.vimrc" ]; then
    print "Configuring .vimrc..."
    git clone https://github.com/sylviot/dot.git $HOME/dot
    sudo ln -s $HOME/dot/.vimrc $HOME/.vimrc
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

yaourt() {
  if [ -n "`(hash yaourt 2>/dev/null) | grep not\ found`" ]; then
    print "> > > Installing YAOURT < < < <"

    git clone https://aur.archlinux.org/package-query.git /tmp/package-query
    cd /tmp/package-query && makepkg -si

    git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
    cd /tmp/yaourt && makepkg -si
  fi
}

$1 $2

