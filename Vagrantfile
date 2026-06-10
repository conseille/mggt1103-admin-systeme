# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.network "private_network", ip: "192.168.56.50"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "VM-Ubuntu-Mggt1103"
    vb.memory = "1024"
    vb.cpus = 1
  end
end