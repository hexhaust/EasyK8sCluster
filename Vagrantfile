NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 2

# Defina aqui o CIDR compativel com a sua rede local.
# Se não for compativel, você tera um erro no prompt.
IP_NW = "192.168.56."
MASTER_IP_START = 10
NODE_IP_START = 20

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false

  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "master" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kubernetes-ha-master#{i}"
        vb.memory = 4096
        vb.cpus = 2
      end
      node.vm.hostname = "master"
      node.vm.network :private_network, ip: "#{IP_NW}#{MASTER_IP_START + i - 1}"
      node.vm.network "forwarded_port", guest: 22, host: 2710 + i - 1

      # Shell provision for master node
      node.vm.provision "shell", inline: <<-SHELL
        sed -i '/^PermitRootLogin/s/prohibit-password/yes/' /etc/ssh/sshd_config
        systemctl restart sshd
      SHELL
    end
  end

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

      # Shell provision for worker nodes
      node.vm.provision "shell", path: "WorkerNodeCreation.sh"
    end
  end
end
