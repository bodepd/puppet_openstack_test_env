Host { ensure => present }

host {
  'jenkins-server': ip => '172.76.0.2';
  'jenkins-agent1': ip => '172.76.0.3';
  'jenkins-agent2': ip => '172.76.0.4';
}

group { 'puppet':
  ensure => 'present',
}

package { ['hiera', 'hiera-puppet']:
  ensure   => present,
  provider => 'gem',
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
