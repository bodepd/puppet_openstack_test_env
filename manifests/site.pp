$jenkins_user         = hiera('jenkins_user', 'jenkins_user')
$jenkins_password     = hiera('jenkins_password', 'password')
$slave_password       = hiera('slave_password', 'password')
$zuul_ssh_private_key = hiera('zuul_ssh_private_key')

Exec {
  logoutput => 'on_failure',
}

node /jenkins-server/ {

  class { 'openstack_test::server':
    jenkins_user        => $jenkins_user,
    jenkins_password    => $jenkins_password,
    create_default_jobs => true,
  }

  class { 'openstack_test::zuul':
    vhost_name           => $::ipaddress_eth1,
    jenkins_apikey       => $jenkins_password,
    zuul_ssh_private_key => $zuul_ssh_private_key,
  }

}

node /jenkins-agent/ {

  class { 'openstack_test::agent':
    server           => '172.76.0.2',
    ssh_password     => $slave_password,
    jenkins_password => $jenkins_password,
  }

}

node /puppetmaster/ {
  # eventually this should use hte puppet master role
  # install puppet master
  class { '::puppet::master':
    certname    => $::fqdn,
    autosign    => true,
    modulepath  => '/etc/puppet/modules',
  }

  # install puppetdb and postgresql
  class { 'puppetdb':
    listen_address     => $puppet_master_bind_address,
    ssl_listen_address => $puppet_master_bind_address,
    database_password  => 'datapass',
  }

  # Configure the puppet master to use puppetdb.
  class { 'puppetdb::master::config':
    puppetdb_server   => $puppet_master_bind_address,
    puppetdb_port     => 8081,
    restart_puppet    => false,
    strict_validation => true,
  }
}
