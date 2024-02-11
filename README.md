# Initial Repo

## Rationale

This repository demonstrates a pattern by which a clever builder can:

- Run a local RockyLinux9 container that is nearly identical a VM or baremetal node
- Bootstrap the local node with Ansible, in a way that is completely identical to how Ansible would bootstrap a remote VM or baremetal host
- Set up that host with:
  - MySQL 8.x
  - Nginx
  - PHP 8.2 + FPM

Given that the Ansible implementation is totally generic, we achieve the objective of using the same automation for the local node as we would for a remote node.

This enables the ability to ship "environments" for:

- development
- testing
- staging
- production

...which are configured and deployed by the same, uniform, repeatable, and reproducible scripts and automation.

## Getting Started

### Requirements

- Install the latest distribution of ruby (rvm is recommended)
- Install the latest Vagrant Beta if running Apple Silicon, else install vanilla Vagrant (brew recommended)
- Install the latest Docker Desktop
- Install Ansible (`pip3 install ansible`)

### Fire up the machine

### Fresh copy

```sh
vagrant up
vagrant ssh
```

### Connect to services

#### MySQL (from your local terminal)

```sh
mysql -h listlocal -u localadmin -plocaladmin
```

#### Nginx (from your local browser)

<http://listlocal>

### Other useful things

```sh
# to re-run Ansible
vagrant provision

# to rebuild a fresh machine & execute a fresh run of Ansible
vagrant reload --provision
```

### Notes

All packages and software have been installed with default settings.

It is recommended to colocate your code alongside the files in this repository to achieve the lowest-friction build, deploy, and development experiences.

You can use Docker to mount your code directly into the container, or you can use the Dockerfile to copy and set up your application at machine build-time.

Mounting your code directly into the container can provide a "hot-reload" experience on file save, if that's your style.

## Documentation

### Ansible

- [Ansible PlayBook Basics](https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html)

Curious builders are encouraged to read the documentation for the Ansible roles used in this repository.

- [Ansible Role: Firewall](https://github.com/geerlingguy/ansible-role-firewall)
- [Ansible Role: EPEL Repo](https://github.com/geerlingguy/ansible-role-repo-epel)
- [Ansible Role: Remi Repo](https://github.com/geerlingguy/ansible-role-repo-remi)
- [Ansible Role: MySQL](https://github.com/geerlingguy/ansible-role-mysql)
- [Ansible Role: Nginx](https://github.com/geerlingguy/ansible-role-nginx)
- [Ansible Role: PHP](https://github.com/geerlingguy/ansible-role-php)
- [Ansible Role: PHP-Versions](https://github.com/geerlingguy/ansible-role-php-versions)

### Vagrant

- [Vagrant Docs](https://www.vagrantup.com/)
- [Vagrant Docker Provider](https://developer.hashicorp.com/vagrant/docs/providers/docker/basics)
- [Vagrant Ansible Provisioner](https://developer.hashicorp.com/vagrant/docs/provisioning/ansible_intro)

This setup uses the `vagrant-hostmanager` plugin. This is installed for you, automatically.

The hostmanager plugin will dynamically and automatically map the local IP of your vagrant guest into your local `hosts` file, so that you can access services inside the vagrant guest from your local machine.

See here:

```rb
  config.vm.hostname = "listlocal"

  # Set the name of the VM. See: http://stackoverflow.com/a/17864388/100134
  config.vm.define :listlocal do |listlocal|
    listlocal.vm.network "forwarded_port",  guest: 3306,  host: 3306,   protocol: "tcp"
    listlocal.vm.network "forwarded_port",  guest: 80,    host: 80,     protocol: "tcp"
  end
```

As you can see, we bind `mysql` and `http` locally. You can access them as though they're running on your localhost.
