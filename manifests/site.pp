$jenkins_user         = hiera('jenkins_user', 'jenkins_user')
$jenkins_password     = hiera('jenkins_password', 'password')
$slave_password       = hiera('slave_password', 'password')
$zuul_ssh_private_key = hiera('zuul_ssh_private_key')
$jenkins_apikey       = hiera('jenkins_apikey')

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
    jenkins_apikey       => $jenkins_apikey,
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
