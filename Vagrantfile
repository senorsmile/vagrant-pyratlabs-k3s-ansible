# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = [
  { :hostname => 'vagrant-k3s-master01',  
    :ip => '192.168.85.101', 
    :forward => '4101', 
    # :box => 'ubuntu/bionic64',
    # :ram => 2048, 
    # :cpus => 1, 
  },
  { :hostname => 'vagrant-k3s-master02',  
    :ip => '192.168.85.102', 
    :forward => '4102', 
  },
  { :hostname => 'vagrant-k3s-master03',  
    :ip => '192.168.85.103', 
    :forward => '4103', 
  },
  { :hostname => 'vagrant-k3s-node01',  
    :ip => '192.168.85.111', 
    :forward => '4111', 
  },
  { :hostname => 'vagrant-k3s-node02',  
    :ip => '192.168.85.112', 
    :forward => '4112', 
  },
  { :hostname => 'vagrant-k3s-node03',  
    :ip => '192.168.85.113', 
    :forward => '4113', 
  },
]


$bootstrap = <<-SCRIPT
  #!/usr/bin/env bash

  set -euo pipefail # strict mode
  #set -x

  debug_echo() {
    echo "*********************************"
    echo "TASK: $@"
    echo "*********************************"
    echo "   "
  }

  apt_update() {
    last_update=$(stat -c %Y /var/cache/apt/pkgcache.bin)
    now=$(date +%s)
    if [ $((now - last_update)) -gt 3600 ]; then
      sudo apt-get update
    fi
  }

  apt_install() {
    apt_update

    install='no'

    perl_dpkg_find=$(cat <<'HERE'
      my $installed=0;
      my $found=0;

      my $dpkg_stdout = qx(dpkg --get-selections | grep ${pkgname} 2>/dev/null);
      my $dpkg_rc = $? >> 8;

      if ($dpkg_rc == 0) {
        $installed=1;
        $found=1;
        print "INSTALLED\n";
        exit(0);
      } 

      if ($dpkg_rc != 0) {
        my $text = "Verify that apt-cache finds it at all";
        my $apt_search_stdout = qx(sudo apt-cache search . | grep ${pkgname});

        my $apt_search_rc = $? >> 8;

        if ($apt_search_rc == 0) {
          print "NOT_INSTALLED\n";
        } else {
          print "NOT_FOUND\n";
        }
      }

HERE
    )



    for pkg in "${@}"; do
      #echo -en "*** Apt install: ||${pkg}||"
      check_pkg=$(perl -s -e "${perl_dpkg_find}" -- -pkgname="${pkg}")
      echo "*** ${check_pkg} ||${pkg}|| "

      if [[ ${check_pkg} == 'NOT_INSTALLED' ]]; then
        install='yes'
        sudo apt-get install -y "${pkg}"
      fi

    done

    #if [ $install = 'yes' ]; then
    #  sudo apt-get install -y "${@}"
    #fi
  }

  ansible_apps=(
    build-essential
    software-properties-common 
    
    gcc
    python-setuptools 
    python-pip
    python-dev 

  )

  install_ansible() {
    debug_echo "Apt manual update"
    sudo apt-get update

    debug_echo "Apt install ansible prereqs"
    apt_install "${ansible_apps[@]}"

    debug_echo "Pip install ansible"
    if ! which ansible >/dev/null 2>&1; then 
      sudo pip install ansible
      #sudo pip install ansible==2.5.3
      #sudo pip install ansible==2.3.3
    fi

    debug_echo "Done installing ansible"
  }

  apps=(
    ifupdown #fix missing on ubuntu 18.04, needed by vagrant
    htop
    vim
    curl
    wget
    #nmap # not on ubuntu 18.04
    tmux
    #build-essential
  )

  run() {
    #--------------------
    ## install ansible
    #--------------------
    # install_ansible

    #--------------------
    ## install basics
    #--------------------
    debug_echo "Apt install basics"
    apt_install "${apps[@]}"
  }

  time run
SCRIPT


Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = node[:box] ? node[:box] : "ubuntu/focal64"
      nodeconfig.vm.network :private_network, ip: node[:ip]
      nodeconfig.vm.network :forwarded_port, guest: 22, host: node[:forward], id: 'ssh'

      # disable for wsl
      nodeconfig.vm.synced_folder '.', '/vagrant', disabled: true


      memory = node[:ram]  ? node[:ram]  : 2048;
      cpus   = node[:cpus] ? node[:cpus] : 1;

      

      nodeconfig.vm.provider :virtualbox do |vb|

        # fix for wsl
        vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]


        vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "90",
          "--cpus", cpus.to_s,
          "--memory", memory.to_s,
        ]


        #vb.gui = true

      end
    end

    #config.vm.provision "shell", inline: $bootstrap

    #if node[:hostname] == 'jenkins-master'
    #  config.vm.provision "ansible_local" do |ansible|
    #    ansible.playbook = "jenkins-master.yml"
    #    ansible.compatibility_mode = "2.0"
    #    ansible.install = false
    #  end
    #  #config.vm.synced_folder ".", "/vagrant"
    #end

  end
end
