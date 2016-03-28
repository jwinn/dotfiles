# Vim configuration

Opted to use pathogen (again) to simplify? things.
Using submodules for git addons

## get started
```
git clone git@github.com:jwinn/dotfiles <dotfiles>
```

### Unix/Linux/OSX
```
ln -sf <dotfiles>/vim ~/.vim
ln -sf <dotfiles>/vim/vimrc ~/.vimrc
```

### windows
```
xcopy /e /q <dotfiles>\vim %HOME%
xcopy /q <dotfiles>\vim\vimrc %HOME%\vimrc
```

### all
```
cd <dotfiles>/vim
git submodule init
git submodule update
```

## add new addon
```
cd ~/.vim
- OR -
cd %HOME%\vim

git submodule init
git submodule add <git_path> bundle/<addon>
git commit -m <comment>
git push
```

## update existing submodules
```
```
