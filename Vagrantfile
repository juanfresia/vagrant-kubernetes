# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

def check_plugin()
  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest is not installed - please execute "vagrant plugin install vagrant-vbguest" !'
  end
end

check_plugin()

yaml = YAML.load_file('./config.yaml')
nodes = yaml['nodes']
IMAGE = yaml['machine']['image']
MEMORY = yaml['machine']['memory']
CPUS = yaml['machine']['cpus']
BASENAME = "node-"

Vagrant.configure(2) do |config|

  config.vm.box = IMAGE

  config.vm.provider "virtualbox" do |vb|
    vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
    vb.memory = MEMORY
    vb.cpus = CPUS
    vb.linked_clone = true
  end

  # Configure each machine independently
  nodes.each do |node|
    index = (yaml['nodes'].index(node)+1).to_s
    name = BASENAME+index

    node_ip = node['ip']
    node_role = node['role']
    node_disks = node['disks']

    config.vm.define name do |box|
      box.vm.network "private_network", ip: node_ip
      box.vm.hostname = name
      box.vm.provider "virtualbox" do |vb|
        vb.name = name
      end

      box.vm.provision "shell" do |s|
        s.env = {
            "NODE_IP"   => node_ip,
            "NODE_ROLE" => node_role
        }
        s.privileged = true
        s.path = "provision.sh"
      end

    end
  end
end
