# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2

IP_NW = "192.168.56."
MASTER_IP_START = 10
NODE_IP_START = 20
LB_IP_START = 30

# Sets up hosts file and DNS
def setup_dns(node)
  # Set up /etc/hosts
  node.vm.provision "setup-hosts", :type => "shell", :path => "scripts/setup-hosts.sh" do |s|
    s.args = ["enp0s8", node.vm.hostname]
  end
  # Set up DNS resolution
  node.vm.provision "setup-dns", type: "shell", :path => "scripts/update-dns.sh"
end

# Runs provisioning steps that are required by masters and workers
def provision_kubernetes_node(node)
  # Set up kernel parameters, modules and tunables
  node.vm.provision "setup-kernel", :type => "shell", :path => "scripts/setup-kernel.sh"
  # Restart
  node.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = "echo Rebooting"
    shell.reboot = true
  end
  # Set up DNS
  setup_dns node
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  config.vm.box = "ubuntu/jammy64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Provision Master Nodes
  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "master-#{i}" do |node|
      # Name shown in the GUI
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-ha-master-#{i}"
        # vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.memory = 2048    # More needed to run e2e tests at end
        vb.cpus = 3
      end
      node.vm.hostname = "master-#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"
      provision_kubernetes_node node
    end
  end

  # Provision Load Balancer Node
  config.vm.define "loadbalancer" do |node|
    node.vm.provider "virtualbox" do |vb|
    #   vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.name = "kubernetes-ha-lb"
      vb.memory = 512
      vb.cpus = 1
    end
    node.vm.hostname = "loadbalancer"
    node.vm.network :private_network, ip: IP_NW + "#{LB_IP_START}"
    node.vm.network "forwarded_port", guest: 22, host: 2730
    setup_dns node
  end

  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "worker-#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        # vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.name = "kubernetes-ha-worker-#{i}"
        vb.memory = 2048
        vb.cpus = 2
      end
      node.vm.hostname = "worker-#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"
      provision_kubernetes_node node
    end
  end
end
