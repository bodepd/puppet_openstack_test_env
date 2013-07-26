#
# Ubuntu virtual machines for testing jenkins
#
Vagrant::Config.run do |config|

  config.vm.box     = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  ssh_forward_port = 2244
  puppet_options = '--verbose --debug --trace'

  [
   {'jenkins_server' =>
     {
       'memory'   => 512,
       'ip1'      => '172.76.0.2',
       'run_mode' => :apply,
     }
   },
   {'jenkins_agent1' =>
     {'memory'   => 512,
      'ip1'      => '172.76.0.3',
      'run_mode' => :apply,
     }
   },
   {'jenkins_agent2' =>
     {
       'memory'   => 512,
       'ip1'      => '172.76.0.4',
       'run_mode' => :apply,
     }
   }
  ].each do |hash|


    name  = hash.keys.first
    props = hash.values.first

    raise "Malformed vhost hash" if hash.size > 1

    config.vm.define name.intern do |agent|

      number = props['ip1'].gsub(/\d+\.\d+\.\d+\.(\d+)/, '\1').to_i
      agent.vm.forward_port(22, ssh_forward_port + number)
      # host only network
      agent.vm.network :hostonly, props['ip1'], :adapter => 2
      agent.vm.network :hostonly, props['ip1'].gsub(/(\d+\.\d+)\.\d+\.(\d+)/) {|x| "#{$1}.1.#{$2}" }, :adapter => 3
      agent.vm.network :hostonly, props['ip1'].gsub(/(\d+\.\d+)\.\d+\.(\d+)/) {|x| "#{$1}.2.#{$2}" }, :adapter => 4

      agent.vm.customize ["modifyvm", :id, "--memory", props['memory'] || 2048 ]
      agent.vm.customize ["modifyvm", :id, "--name", "#{name}.puppetlabs.lan"]
      agent.vm.host_name = "#{name.gsub('_', '-')}.puppetlabs.lan"


      # update repos
      agent.vm.provision :shell, :inline => "apt-get update"

      run_mode = props['run_mode'] || :apply

      agent.vm.provision(:puppet, :pp_path => "/etc/puppet") do |puppet|
        puppet.manifests_path = 'manifests'
        puppet.manifest_file  = 'hosts.pp'
        puppet.module_path    = 'modules'
        puppet.options        = puppet_options
      end

      agent.vm.provision :shell do |shell|
        shell.inline = "/opt/vagrant_ruby/bin/gem uninstall puppet;gem uninstall -x -a puppet;echo -e '#!/bin/bash\npuppet agent $@' > /sbin/puppetd;chmod a+x /sbin/puppetd"
      end

      agent.vm.share_folder("hiera_data", '/etc/puppet/hiera_data', './hiera_data/')

      if run_mode == :apply

        agent.vm.provision(:puppet, :pp_path => "/etc/puppet") do |puppet|
          puppet.manifests_path = 'manifests'
          puppet.manifest_file  = 'site.pp'
          puppet.module_path    = 'modules'
          puppet.options        = puppet_options
        end

      elsif run_mode == :agent

        master = props['master'] || 'puppetmaster.puppetlabs.lan'

        agent.vm.provision(:puppet_server) do |puppet|
          puppet.puppet_server = master
          puppet.options       = puppet_options + ['-t', '--pluginsync']
        end

      else
        puts "Found unexpected run_mode #{run_mode}"
      end
    end
  end
end
