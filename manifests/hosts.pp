Host { ensure => present }

# use a squid proxy!!
class { 'apt':
  proxy_host => '172.16.3.1',
  proxy_port => '3128',
}

host {
  'jenkins-server': ip => '172.16.3.2';
  'jenkins-agent1': ip => '172.16.3.3';
  'jenkins-agent2': ip => '172.16.3.4';
}

group { 'puppet':
  ensure => 'present',
}

include puppet::repo::puppetlabs

Apt::Source<||> -> Package<||>

package { 'rubygems':
  ensure => present,
}
package { 'puppet-common':
  ensure  => '3.2.2-1puppetlabs1',
  require => [Apt::Source['puppetlabs'],Package['rubygems']],
}
package { 'puppet':
  ensure  => '3.2.2-1puppetlabs1',
  require => Package['puppet-common'],
}


file { '/etc/puppet/hiera.yaml':
  content =>
'
---
:backends:
  - yaml
:hierarchy:
  - "%{hostname}"
  - jenkins
  - secure
  - common
:yaml:
   :datadir: /etc/puppet/hiera_data'
}
