# -*- mode: ruby -*-
# vi: set ft=ruby :

max_agents_cpu = case RbConfig::CONFIG['host_os']
  when /darwin/
    `sysctl -n hw.ncpu`.to_i
  when /linux/
    `nproc`.to_i
  else
    2
end - 4

max_agents_memory = `sh -c "free -m | grep Mem: | awk '{print \\$2}'"`.to_i - 4096 / 1024

# Agent デフォルト台数: 3
# `OVERLOAD=1 vagrant up` でバカみたいに VM が立つ
MAX_AGENTS = ENV['OVERLOAD'] ? [max_agents_cpu, max_agents_memory].min : 3

Vagrant.configure('2') do |config|
  config.vm.box = "almalinux/8"
  config.vm.box_version = "8.5.20211208"
  config.ssh.insert_key = false
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 1024
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.define 'monitor' do |n|
    n.vm.provider 'virtualbox' do |vb|
      vb.memory = 4096
      vb.cpus = 4
    end
    n.vm.hostname = 'monitor'
    n.vm.network 'private_network', ip: '192.168.56.254'
    n.vm.network 'forwarded_port', guest: 3000, host: 3000
    n.vm.network 'forwarded_port', guest: 3001, host: 3001
    n.vm.provision 'shell', path: 'monitor_setup.sh'
  end

  (1..MAX_AGENTS).each do |i|
    config.vm.define "agent#{i}" do |n|
      n.vm.hostname = "agent#{i}"
      n.vm.network 'private_network', ip: "192.168.56.#{i+1}"
      n.vm.provision 'shell', path: 'agent_setup.sh'
    end
  end
end
