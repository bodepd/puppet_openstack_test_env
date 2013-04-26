put password in the file:

    hiera_data/secure.yaml

      jenkins_password: XXX
      slave_password: XXX
      jenkins_apikey: XXX
      zuul_ssh_private_key: |
        XXX

right now, you have to run puppet twice

you still need to log in to create jenkins jobs and start zuul
