#!/bin/sh

endpath=$HOME/.dotfiles
today=`date +%Y%m%d`

echo "Cloning from github into ${endpath}"
if [ -d "${endpath}/.git" ]; then
	cd ${endpath} && git pull
else
	git clone https://github.com/jwinn/dotfiles.git $endpath
fi

if [[ -d "${HOME}/.vim" || -f "${HOME}/.vimrc" ]]; then
	echo "Vim settings already exist"
	read -p "Do you want to back them up? [Y/n]" yn
	case $yn in
		[Nn]*)
			echo "Removing vim settings and files"
			rm -rf $HOME/.vim* $HOME/.gvimrc
			break;;
		*)
			echo "Backing up vim settings and files"
			for i in $HOME/.vim* $HOME/.gvimrc
			do
				[ -e $i ] && [ ! -L $i ] && mv $i $i.$today;
			done
	esac
fi

echo "Creating symlinks"
ln -sf ${endpath}/bash_profile ~/.bash_profile
ln -sf ${endpath}/editorconfig ~/.editorconfig
ln -sf ${endpath}/sleep ~/.sleep
ln -sf ${endpath}/wakeup ~/.wakeup
ln -sf ${endpath}/vim ~/.vim
ln -sf ${endpath}/vim/vimrc ~/.vimrc

echo "Creating vim backup and undo folders"
mkdir -p ${endpath}/vim/.backup/undo

echo "Launching Vim to install Bundles.."
SHELL=/bin/sh vim $endpath/vundles.vim +BundleInstall! +BundleClean +qall

echo "Installation complete!"
