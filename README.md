# xdg-data-autoremove 

A shell script which helps you find and delete not used files and folders from uninstalled applications in your XDG folder like ~/.config, ~/.cache, ~/.local/share.

![xdg-data-autoremove-compressed](https://github.com/pawel-0/xdg-data-autoremove/assets/1931622/d458f30c-4418-404c-8a42-6d261362c3d0)

# Why xdg-data-autoremove?
Package manager (e.g. dpkg, rpm, apt, dnf) will in general not delete application files and folder after they were deleted. This may lead to residues on your harddrive and bloat.

# Data safety

xdg-data-autoremove.sh will never removes files by it's own without confirmation. Execution of the script simply prints out all files/folder which would be safe to 

# Dependencies
The following requirements are needed to run xdg-data-autoremove
- [jq](https://github.com/jqlang/jq)


# Installation
Manually clone the repository:

```sh
git clone https://github.com/pawel-0/xdg-data-autoremove
```

# Usage

run `./xdg-data-autoremove.sh`

# Options

```text
 Usage: 
    xdg-data-autoremove.sh [argument]

 Arguments: 
    -h, --help             Print this help message
    --raw                  Outputs only pathes of files/folder
    --remove-all           Remove all files found
    --remove-all-force     Remove all files found
  ```
