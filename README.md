<h1 align="center">
   <img src="./.github/assets/logo.svg" width="100px"><br />
   XDG Unused Data
</h1>

A simple way to identify unused applications data in user directories such as ~./config and ~/.cache.

[![Shellcheck](https://img.shields.io/github/actions/workflow/status/pawel-0/xdg-data-autoremove/shellcheck.yml?event=push&logo=github&label=Shellcheck)](https://github.com/pawel-0/xdg-data-autoremove/actions/workflows/shellcheck.yml) &nbsp;
[![JSON validation](https://img.shields.io/github/actions/workflow/status/pawel-0/xdg-data-autoremove/json_validation.yml?event=push&logo=github&label=JSON%20Validation)](https://github.com/pawel-0/xdg-data-autoremove/actions/workflows/json_validation.yml)&nbsp;
[![Application Support](https://img.shields.io/github/directory-file-count/pawel-0/xdg-data-autoremove/applications?logo=github&label=Applications&color=blue)](https://github.com/pawel-0/xdg-data-autoremove/tree/main/applications)&nbsp;
[![Lizense](https://img.shields.io/github/license/pawel-0/xdg-data-autoremove?logo=github)](https://github.com/pawel-0/xdg-data-autoremove/blob/main/LICENSE)

## Table of Contents

- [About](#about)
- [Hot it works](#how-it-works)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Arguments](#arguments)

## About

A package manager (such as dpkg, rpm, apt, or dnf) generally does not remove application files from user directories. Over time, these folders might accumulate redundant files due to the installation and removal of various applications on the system, leading to clutter.

The goal of xdg-unused-data.sh is to identify this files and folders.

## How it works

The [`applications/`](https://github.com/pawel-0/xdg-data-autoremove/tree/main/applications) folder contains JSON files that provide information about each application, including its executable name and associated files and folders.

The scripts scans for each application. During execution, the script verifies the presence of both the executable and its corresponding files or folders. If the executable is missing but at least one of the associated files or folders exists, it is flagged for attention.

## Dependencies
The following requirements are needed to run xdg-unused-data
- [jq](https://github.com/jqlang/jq)


## Installation

__1. Clone repository:__

```sh
git clone https://github.com/pawel-0/xdg-unused-data
```

__2. Change directory__

```sh
cd xdg-unused-data/
```

__3. Set permission__

```sh
chmod +x ./xdg-unused-data.sh
```

__4. Run application__

```sh
./xdg-unused-data.sh
```

## Arguments
Usage: `xdg-unused-data.sh [argument]`

* `--help` Print help message
* `--raw` Print raw file pathes without colors and additional information to process them further