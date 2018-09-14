# Set up Windows Server 2016 Core with SSH

This repository uses [Vagrant](https://www.vagrantup.com) to setup a Windows Server 2016 Core
headless VM (running in [VirtualBox](https://www.virtualbox.org)). It installs OpenSSH Server
(beta) to simplify using it from a non-Windows command-line environment. [Chocolatey](https://chocolatey.org) is also installed.

## Basic Setup

Download required packages
```
./fetch.sh
```

Then build the machine
```
vagrant up --provider virtualbox
```

Once built, connect to it via WinRM or SSH as the user `vagrant` (password `vagrant`).

## Developer Setup

To build or update the machine with Ruby and C++ developer tools, set the environment variable
`DEVENV=true`.

For example, to update an existing box run
```
env DEVENV=true vagrant provision
```

## Windows Updates

https://docs.microsoft.com/en-us/windows-server/administration/server-core/server-core-servicing

Run `wmic qfe list` to list available updates.

Enable automatic updates
```
cd C:\Windows\system32
net stop wuauserv
cscript scregedit.wsf /AU 4
net start wuauserv
Wuauclt /detectnow
```
