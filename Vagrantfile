# -*- mode: ruby -*-
# vi: set ft=ruby :

node = "DSCPSCore6"
moffolder = "C:/tmp/MOF"

Vagrant.configure("2") do |config|
  config.vm.box = "jacqinthebox/windowsserver2016core"
  config.vm.communicator = "winrm"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 2
    vb.memory = "4096"
  end

  # Set vagrant machine name
  config.vm.hostname = node
  # Configure network
  config.vm.network "forwarded_port", host: 33389, guest: 3389
  config.vm.network "forwarded_port", host: 8080, guest: 80
  config.vm.network "forwarded_port", host: 4443, guest: 443

  # Perform file copy from Local machine to Vagrant box
  config.vm.provision "file",
    source: 'DSC/SourceFiles',
    destination: "C:\\tmp\\SourceFiles"

  # Create MOF
  config.vm.provision "shell",
    path: 'DSC/Config/PS6TestServer.ps1',
    args: [node, moffolder]

  # Invoke MOF file
  config.vm.provision "shell",
    inline: "Start-DSCConfiguration -Path $Args[0] -Force -Wait -Verbose",
    args: [moffolder]

  config.vm.provision "shell",
    inline: "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"

  if ENV['DEVENV']
    config.vm.provision "shell",
      inline: 'choco install -y git cmake mingw 7zip.commandline ag msys2 ruby dependencywalker'
  end
end
