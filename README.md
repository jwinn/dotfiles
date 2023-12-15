# dotfiles

My collection of dot files using [chezmoi] to manage.

Use either the [Bootstrap](#bootstrap) or [Git Clone and Install](#git-clone-and-install) method.

### Bootstrap

> `git` is required, as well as either `curl` or `wget`

`curl`
```sh
sh -c "$(curl -fsSL https://codeberg.org/jwinn/dotfiles/raw/branch/main/bootstrap.sh)"
```

*- or -*

`wget`
```sh
sh -c "$(wget -qO- https://codeberg.org/jwinn/dotfiles/raw/branch/main/bootstrap.sh)"
```

### Git Clone and Install

> `git` is required

**Clone**

`HTTPS`
```sh
git clone https://codeberg.org/jwinn/dotfiles.git
```

*- or -*

`SSH`
```sh
git clone git@codeberg.org:jwinn/dotfiles.git
```

#### Install

> `cd` into the folder where the repo was cloned, e.g. `dotfiles`

```sh
cd dotfiles && sh install.sh && cd -
```

[chezmoi]: https://chezmoi.com