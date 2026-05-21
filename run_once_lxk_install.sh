## zsh install
sudo apt install zsh -y
zsh
# omz install
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
source ~/.zshrc
# omz plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo apt-get install autojump
source ~/.zshrc
# starship
curl -sS https://starship.rs/install.sh | sh
# download nerd font https://www.nerdfonts.com/font-downloads
