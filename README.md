# vagrant-pyratlabs-k3s-ansible
vagrant example of https://github.com/PyratLabs/ansible-role-k3s

## Use
```#
# clone repo
git clone git@github.com:senorsmile/vagrant-pyratlabs-k3s-ansible.git
cd vagrant-pyratlabs-k3s-ansible/

# update git submodules
git submodule update --init --recursive 

# configure vm's
vagrant up           # start 6 (virtualbox) vm's
bash run_vagrant.sh  # run ansible against the vm's
```
