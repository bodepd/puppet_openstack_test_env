Host { ensure => present }

host {
  'jenkins-server': ip => '172.76.0.2';
  'jenkins-agent1': ip => '172.76.0.3';
  'jenkins-agent2': ip => '172.76.0.4';
}

group { 'puppet':
  ensure => 'present',
}

include puppet::repo::puppetlabs
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
