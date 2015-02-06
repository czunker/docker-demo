# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.4.0"

BOX_NAME = "docker-demo"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.define BOX_NAME do |t| end

  config.vm.hostname = "#{BOX_NAME}.localdomain"
  config.vm.network :public_network
  config.vm.provider :virtualbox do |vbox|
    vbox.name = BOX_NAME
    vbox.memory = 3096
  end

#  config.vm.provision :shell, :inline => "echo 'nameserver 8.8.8.8 >> /etc/resolv.conf'"
  config.vm.provision :shell, :inline => "mkdir -p /var/lib/cloud/instance; touch /var/lib/cloud/instance/locale-check.skip"
  config.vm.provision :shell, :inline => "curl -sSL https://get.docker.com/ubuntu/ | sudo sh"
  config.vm.provision "docker", version: "1.4.1"
  # pull during build inside the vagrant box does not work
  config.vm.provision :shell, :inline => "docker pull prom/container-exporter"
  config.vm.provision :shell, :inline => "docker pull stackexchange/bosun"
  config.vm.provision :shell, :inline => "mkdir -p /opt/scollector; cp /vagrant/webserver_scollector/scollector-linux-amd64 /opt/scollector/scollector && chmod +x /opt/scollector/scollector"
  #config.vm.provision :shell, :inline => "docker run -d -p 18080:8080 -v /sys/fs/cgroup:/cgroup -v /var/run/docker.sock:/var/run/docker.sock prom/container_exporter"
end

