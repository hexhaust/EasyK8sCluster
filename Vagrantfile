NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2
NUM_LOADBALANCER = 1

IP_NW = "192.168.56."
MASTER_IP_START = 10
NODE_IP_START = 20
LOADBALANCER_IP_START = 30

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false

  # Master Node conf
  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "master#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-ha-master#{i}"
        vb.memory = 4096
        vb.cpus = 2
      end
      node.vm.hostname = "master#{i}"
      node.vm.network :private_network, ip: "#{IP_NW}#{MASTER_IP_START + i - 1}"
      node.vm.network "forwarded_port", guest: 22, host: 2710 + i - 1
      node.vm.provision "shell", path: "ControlPlaneCreation.sh"
    end
  end

  # Worker Node conf
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "worker#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-ha-worker#{i}"
        vb.memory = 2048
        vb.cpus = 4
      end
      node.vm.hostname = "worker#{i}"
      node.vm.network :private_network, ip: "#{IP_NW}#{NODE_IP_START + i - 1}"
      node.vm.network "forwarded_port", guest: 22, host: 2720 + i - 1
      node.vm.provision "shell", path: "WorkerNodeCreation.sh"
    end
  end

  # Load Balancer conf
  (1..NUM_LOADBALANCER).each do |i|
    config.vm.define "loadbalancer#{i}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-ha-loadbalancer#{i}"
        vb.memory = 1024
        vb.cpus = 1
      end
      node.vm.hostname = "loadbalancer#{i}"
      node.vm.network :private_network, ip: "#{IP_NW}#{LOADBALANCER_IP_START + i - 1}"
      node.vm.network "forwarded_port", guest: 22, host: 2730 + i - 1

      #HAProxy conf
      node.vm.provision "file", source: "./haproxy.cfg", destination: "/tmp/haproxy.cfg"
      
      # Provisionando o Shell para a maquina LB
      node.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get install -y haproxy
        sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
        sudo systemctl restart haproxy
      SHELL
    end
  end
end
