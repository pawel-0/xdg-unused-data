<h1 align="center">
   <img src="./.github/assets/logo.svg" width="100px"><br />
   XDG Data Autoremove
</h1>

<p align="center">
   A simple way to identify unused and leftover files from removed applications in your XDG directories.
</p>

<p align="center">
   <a href="https://github.com/pawel-0/xdg-data-autoremove/actions/workflows/shellcheck.yml">
      <img src="https://img.shields.io/github/actions/workflow/status/pawel-0/xdg-data-autoremove/shellcheck.yml?event=push&logo=github&label=Shellcheck">
   </a>
   &nbsp;&nbsp;
   <a href="https://github.com/pawel-0/xdg-data-autoremove/actions/workflows/json_validation.yml">
      <img src="https://img.shields.io/github/actions/workflow/status/pawel-0/xdg-data-autoremove/json_validation.yml?event=push&logo=github&label=Shellcheck">
   </a>
   &nbsp;&nbsp;
   <a href="https://github.com/pawel-0/xdg-data-autoremove/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/pawel-0/xdg-data-autoremove?logo=github">
   </a>
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#dependencies">Dependencies</a> •
  <a href="#installation">Installation</a> •
  <a href="#arguments">Arguments</a>
</p>

# About

Package manager (e.g. dpkg, rpm, apt, dnf) will in general not delete application files in ~/.config, ~/.cache, ~/.local, etc. If you installed bunch of applications in the past, the chance your system is cluttered.


# Dependencies
The following requirements are needed to run xdg-data-autoremove
- [jq](https://github.com/jqlang/jq)


# Installation

__1. Clone repository:__

```sh
git clone https://github.com/pawel-0/xdg-data-autoremove
```

__2. Change to directory__

```sh
cd xdg-data-autoremove/
```

__3. Set permission__

```sh
chmod +x ./xdg-data-autoremove.sh
```

__4. Run application__

```sh
./xdg-data-autoremove.sh
```

# Arguments
Usage: `xdg-data-autoremove.sh [argument]`

* `--help` Print help page
* `--raw` Print raw file pathes without colors and additional information
* `--remove-all` Remove found files. You have to confirm to delete files
* `--remove-all-force` Remove found files __WITHOUT__ need for confirmation
