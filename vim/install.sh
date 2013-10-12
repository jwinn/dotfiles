#!/bin/sh

endpath=$HOME/.vim
today=`date +%Y%m%d`

if [[ -d $endpath || -f $Home/.vimrc ]]; then
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

echo "Cloning from github into ${endpath}"
if [ -d $endpath/.git ]; then
	cd ${endpath} && git pull
else
	git clone https://github.com/jwinn/dotvim.git $endpath
fi

echo "Creating symlinks"
ln -sf ${endpath}/vimrc ~/.vimrc

echo "Creating backup and undo folders"
mkdir -p ${endpath}/.backup/undo

echo "Launching Vim to install Bundles.."
SHELL=/bin/sh vim $endpath/vundles.vim +BundleInstall! +BundleClean +qall

echo "Installation complete!"
