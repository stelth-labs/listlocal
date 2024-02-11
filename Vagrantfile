VAGRANTFILE_API_VERSION = "2" # Don't TOUCH THIS

# Declare list of required plugins
required_plugins = %w(vagrant-hostmanager)

# Install the required plugins
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

# Configure the Guest (as an ssh-enabled container === speed!)
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "docker" do |container, override|
    container.build_dir       = "."
    container.has_ssh         = true
    container.privileged      = true
    container.remains_running = true
    override.ssh.username     = "vagrant"
    container.create_args     = ["--cgroupns=host"]
  end

  config.vm.hostname = "listlocal"

  # Set the name of the VM. See: http://stackoverflow.com/a/17864388/100134
  config.vm.define :listlocal do |listlocal|
    listlocal.vm.network "forwarded_port", guest: 3306,  host: 3306,   protocol: "tcp"
  end

  # Ansible provisioner.
  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "provisioning/playbook.yml"
    ansible.become = true
  end
end
