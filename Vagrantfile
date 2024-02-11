VAGRANTFILE_API_VERSION = "2" # Don't TOUCH THIS

# Declare the required plugins
required_plugins = %w(vagrant-hostmanager)

# Install the required plugins
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

# Configure the Guest (as an ssh-enabled container === speed!)
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |container, override|
    container.build_dir = "."
    container.has_ssh = true
    container.remains_running = true
    override.ssh.username = "vagrant"
  end
end
