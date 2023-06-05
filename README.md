# EasyK8sCluster
Uma jeito facil (mas nao rapido) de criar seu Cluster Kubernetes com kubeadm para estudos e testes

## Dependencias
É necessário instalar o VirtualBox e o Vagrant na sua máquina
### Linux
https://www.virtualbox.org/wiki/Linux_Downloads
https://developer.hashicorp.com/vagrant/downloads
### MacOS
https://download.virtualbox.org/virtualbox/7.0.8/VirtualBox-7.0.8-156879-OSX.dmg
https://developer.hashicorp.com/vagrant/downloads

### Windows
https://download.virtualbox.org/virtualbox/7.0.8/VirtualBox-7.0.8-156879-Win.exe
https://developer.hashicorp.com/vagrant/downloads


## Requisitos
Essa configuração atual necessita de pelo menos 8GB de RAM livre, são 4 para o Control-Plane e 4 para os Workers, 2GB em cada.
É possivel diminuir essa spec no Vagrantfile. Vai funcionar? Descubra.

## Vagrant Up!
Crie uma pasta/diretório isolado na sua máquina, e clone esse repositório.

Acesse a pasta EasyK8sCluster e dentro dela pela linha de comando, execute:
```yaml
vagrant up
```
Note que isso pode apresentar erro, e talvez seja necessário digitar:
```yaml
vagrant init
```
### Possivel erro de CIDR
Quando você digitar vagrant up, esse erro pode aparecer:
```yaml
The IP address configured for the host-only network is not within the
allowed ranges. Please update the address used to be within the allowed
ranges and run the command again.

  Address: 192.168.5.10
  Ranges: 192.168.56.0/21

Valid ranges can be modified in the /etc/vbox/networks.conf file. For
more information including valid format see:

  https://www.virtualbox.org/manual/ch06.html#network_hostonly
```
Caso aconteça, basta você alterar a variável IP_NW no Vagrantfile. Nesse caso eu vou ter que utilizar o IP 192.168.56.x, como apresenta em Ranges.

Você irá provisionar 3 máquinas, 1 Master Node e 2 Worker Nodes com os pacotes já instalados na versão 1.25.0 do Kubernetes.
O kubeadm tende a apresentar erros nas versões mais novas do Kubernetes. 1.26 pra cima. Sendo assim a 1.25 já nos ajuda, tem umas features bem legais e é claro, sempre da pra habilitar aquele feature-gate que todos nós gostamos :D

## Configuração do Cluster
Chegou ate aqui? Já da uma estrelinha no repo, vai funcionar com certeza na sua máquina!

Então, para logar nas máquinas você pode apenas digitar:
```yaml
vagrant ssh master
vagrant ssh worker1
vagrant ssh worker2
```
Isso em terminais separados, obviamente.

### APENAS no Master Node
Execute:
```yaml
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.25.0 --apiserver-advertise-address 192.168.56.10
```
*LEMBRE-SE DE ALTERAR O apiserver-advertise-address 192.168.x.10 PARA O CIDR QUE VOCÊ INFORMOU. O FINAL DO IP DO MASTER SEMPRE SERÁ 10, O QUE PODE MUDAR É O NÚMERO APÓS O 168.*

Aguarde alguns minutos, isso vai provisionar o Control Plane inteiro, com certificados e API Server.

Finalizado o kubeadm init, execute então:
```yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Isso vai fazer com que possamos executar comandos do kubernetes com o usuário vagrant, sem precisar virar root.

Depois instale o Calico para comunicação entre os nodes, pods e services:
```yaml
kubectl apply -f https://docs.projectcalico.org/archive/v3.16/manifests/calico.yaml
```
Após isso verifique o status do seu Master Node com:
```yaml
kubectl get nodes
```
Você pode ver o Node como NotReady:
```yaml
vagrant@master:~$ kubectl get nodes
NAME     STATUS     ROLES           AGE   VERSION
master   NotReady   control-plane   56s   v1.25.0
```
Vamos arrumar isso agora! Instale o Calico:
```yaml
kubectl apply -f https://docs.projectcalico.org/archive/v3.16/manifests/calico.yaml
```
Aguarde alguns minutos e ele vai ficar assim:
```yaml
vagrant@master:~$ kubectl get nodes
NAME     STATUS   ROLES           AGE     VERSION
master   Ready    control-plane   3m19s   v1.25.0
```
Vamos agora juntar os outros 2 Worker Nodes ao Cluster!
```yaml
sudo kubeadm token create --print-join-command
```  
O output sera algo parecido com isso:
```yaml
vagrant@master:~$ sudo kubeadm token create --print-join-command
kubeadm join 192.168.56.10:6443 --token xxxxx.xxxxxxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
``` 
Copie esse ouput a partir do kubeadm e execute o comando inteiro com sudo nos *Worker Nodes 1 e 2*

Cerca de 1-2 minutos após o comando finalizar nos nodes, você já pode verificar os nodes no Master:
```yaml
vagrant@master:~$ kubectl get nodes
NAME      STATUS   ROLES           AGE     VERSION
master    Ready    control-plane   6m53s   v1.25.0
worker1   Ready    <none>          27s     v1.25.0
worker2   Ready    <none>          24s     v1.25.0
```

Tudo lindo!?
Ainda não.. Dá uma passada no arquivo Post-Configs que ainda temos 2 probleminhas para resolver. Falei que seria fácil, não rápido hehe














