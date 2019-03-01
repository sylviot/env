#! /bin/bash


preinstall_yaourt() {
  print "> > > Installing $BLUE YAOURT $DEFAULT < < < <"
  
  #sudo pacman -S --needed --noconfirm base-devel yajl
  git clone https://aur.archlinux.org/package-query.git /tmp/package-query
  cd /tmp/package-query && makepkg -si

  git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
  cd /tmp/yaourt && makepkg -si

}

install_arch () {
  print "> > > Installing $BLUE ARCH LINUX $DEFAULT < < < <"

  PACKAGES="xorg-server xorg-xinit xorg-twm xorg-xclock xterm xfce4 lightdm "
  PACKAGES+="wget htop git vim zsh bash-completion ctags docker unrar "
  # PACKAGES+="qemu-kvm qemu virt-manager virt-viewer libvirt-bin "
  #PACKAGES+="chromium firefox opera vlc clementine"

  sudo pacman -Sy

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling pacman packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi
  
  preinstall_yaourt
  
  PACKAGES="google-chrome lightdm-webkit2-greeter lightdm-webkit-theme-litarvan"

  #yaourt installs
  if [ -n "`(yaourt -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $PACKAGES
  fi

  configure_desktop
  configure_vim
  configure_zsh
  configure_docker
}

configure_desktop() {
  print "Configuring desktop..."

  #Configure zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  chsh -s $(which zsh)
  
  #Configure xinitrc
  #echo -e "#! /bin/sh\nexec startxfce4" > ~/.xinitrc
  #cp /etc/X11/xinit/xinitrc ~/.xinitrc

  #Configure lightdm.conf
  sudo sed -i -r -e 's/\#(greeter-session=).*$/\1lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
  sudo sed -i -r -e 's/^(webkit_theme.*=).*$/\1 litarvan/' /etc/lightdm/lightdm-webkit2-greeter.conf
  sudo systemctl enable lightdm
  
  # Download Rele Theme
  #curl -o /tmp/rele.tar.bz2 https://dl.opendesktop.org/api/files/downloadfile/id/1462392025/s/947eec5cfb08c2bb291190370343f799/t/1527263464/u/60272/77260-rele-xfce4.tar.bz2
  #tar -xjvf /tmp/rele.tar.bz2
  #sudo cp -R /tmp/Rele /usr/share/themes/Rele

  #download image backgroud
  #xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /temp/background.jpg
}

configure_docker() {
  print "Configuring docker..."
  #if [-n "`systemctl is-enabled docker | grep disabled`"]; then
  sudo systemctl enable docker
  sudo usermod -aG docker sylviot

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
