# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "cartodb" do |cartodb|
    cartodb.vm.box = "ubuntu/precise64"
    cartodb.vm.hostname = "cartodb"
    cartodb.vm.network "private_network", ip: "192.168.20.100"

    cartodb.vm.synced_folder ".", "/vagrant", disabled: true
    cartodb.vm.synced_folder "../cartodb/cartodb", "/opt/cartodb", type: "nfs", mount_options: ['actimeo=1']
    cartodb.vm.synced_folder "../cartodb/windshaft-cartodb", "/opt/windshaft-cartodb", type: "nfs"
    cartodb.vm.synced_folder "../cartodb/cartodb-postgresql", "/opt/cartodb-postgresql", type: "nfs"
    cartodb.vm.synced_folder "../cartodb/cartodb-sql-api", "/opt/cartodb-sql-api", type: "nfs"

    cartodb.vm.provision "shell", path: "./provision.sh", privileged: false

    cartodb.ssh.forward_x11 = true

    cartodb.vm.network :forwarded_port, guest: 3000, host: 3000
    cartodb.vm.network :forwarded_port, guest: 8080, host: 8080
    cartodb.vm.network :forwarded_port, guest: 8181, host: 8181

    cartodb.vm.provider :virtualbox do |v|
      v.memory = ENV.fetch("CARTODB_MEM", 4096)
      v.cpus = ENV.fetch("CARTODB_DATABASE_CPU", 3)
    end
  end
end
