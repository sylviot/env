#!/bin/bash

GIT_USERNAME="sylviot"
GIT_EMAIL="sylvio.tavares@hotmail.com"

print () {
  DEFAULT='\033[0;31m'
  NC='\033[0m'
  echo -e "$DEFAULT $1 $NC"
}

with_pacman() {
  if [ -n "`(sudo pacman -Qk $@ 2>&1) | grep was\ not\ found`" ]; then
    print "> > > INSTALL WITH pacman ($@) < < <"
    sudo pacman -Sq --needed --noconfirm $@
  fi
}

with_yaourt() {
  if [ -n "`(yaourt -Qk $@ 2>/dev/null) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $@
  fi
}


# update() {
#   print "> > > UPDATE Manjaro sylviot < < <"

#   sudo pacman-mirrors -g --geoip
#   sudo pacman -Suy --noconfirm
#   yaourt -Suyy --aur --noconfirm

#   print "> > > FINISH UPDATE < < <"
# }

# install() {
#   yaourt

#   desktop
#   development
#   vim
# }


# GLOBAL FUNCTIONS #
aur() {
  if ! hash yaourt 2>/dev/null; then
    print "> > > Installing YAOURT < < < <"

    git clone https://aur.archlinux.org/package-query.git /tmp/package-query
    cd /tmp/package-query && makepkg -si

    git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
    cd /tmp/yaourt && makepkg -si
  fi
  
  print "> > > UPDATE YAOURT < < < <"
  yaourt -Suyy --aur --noconfirm
}

desktop() {
  print "> Configuration desktop..."

  with_yaourt "lightdm-webkit2-greeter lightdm-webkit-theme-litarvan"

  print "> Configure lightdm"
  sudo sed -i -r -e 's/(greeter-session=).*$/\1lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
  sudo sed -i -r -e 's/^(webkit_theme.*=).*$/\1 litarvan/' /etc/lightdm/lightdm-webkit2-greeter.conf
  sudo systemctl enable lightdm
}

# Obsolete
# development() {

#   sudo ln -s ~/env/bin/* /usr/local/bin/ 2>/dev/null
# }

# ToDo - problema para instalar o chrome... 
_chrome() {
  print "> Try install chrome..."
  with_yaourt "google-chrome"
}

_chromium() {
  print "> Try install chromium..."
  with_pacman "chromium"
}

_docker() {
  print "> Try install docker..."
  with_pacman "docker"

  if [ -n "`(systemctl is-enabled docker) | grep disabled`" ]; then
    print "> Docker systemctl ENABLE"
    sudo systemctl enable docker
    sudo usermod -aG docker sylviot
  fi
}

_dotnet() {
  if ! hash dotnet 2>/dev/null; then
    print "> > > Install dotnet... < < <"

    wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh

    sudo sh /tmp/dotnet-install.sh --install-dir /opt/dotnet -Channel Current -Version latest
    
    sudo sh /tmp/dotnet-install.sh --install-dir /opt/dotnet -Channel LTS -Version latest
    
    export PATH="$PATH:/opt/dotnet"
  fi
}

_git() {
  print "> > > Try install git... < < <"
  with_pacman "git"

  if [ -z "`(git config --list)` | grep user" ]; then
    print "> > > Configuring git < < <"
    git config --global user.name $GIT_USERNAME
    git config --global user.email $GIT_EMAIL
    ssh-keygen -t rsa -b 4096 -C $GIT_EMAIL
  fi
}

_nodejs() {
  print "> > > Try install nodejs with npm and yarn... < < <"
  with_pacman "nodejs npm yarn"
}

_utils() {
  print "> Try install utils base..."

  # with_pacman "xf86-input-mouse xf86-input-keyboard xf86-video-ati"
  with_pacman "bash-completion cmake htop unrar wget"
}

_vim() {
  print "> Installing vim..."
  with_pacman "vim"

  print "> Configuring vim..."

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

_zsh() {
  print "> Try install zsh..."
  with_pacman "zsh"
  
  if [ ! -z "`echo $SHELL | grep zsh`" ]; then
    print "Configuring zsh..."
    sudo chsh -s $(which zsh)
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print "> Configuring oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  fi
}


modules=$(whiptail --title "ENV Manjaro by sylviot" --clear --ok-button "Install" --checklist --fb \
"Choose which modules install:" 40 100 15 \
"aur" "Yaourt AUR" ON \
"_chrome" "Google Chrome Browser" OFF \
"_chromium" "Chromium Browser" OFF \
"_docker" "Docker Container" OFF \
"_dotnet" "DOTNET Environment (LTS + Current)" OFF \
"_git" "GIT Source code" OFF \
"_nodejs" "NodeJS with NPM" OFF \
"_zsh" "ZSH with Oh-my-zsh" OFF \
"_vim" "VIM Text Editor + Plugin" OFF \
"_utils" "bash-completion cmake ctags htop unrar wget" OFF 3>&1 1>&2 2>&3)

status=$?
if [ $status = 0 ]
then
  sudo pacman -Suy --noconfirm

  for i in $modules; do
    # echo $i
    $(echo $i | tr -d '"')
  done

  print "> > > END < < <"
else
   echo "No install any module."
fi
