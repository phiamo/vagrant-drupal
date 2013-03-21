$drupal_version = '7.14'

Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}
class setup {
    exec { 'update':
        command => 'sudo apt-get update'
    }

    exec { 'upgrade':
        command => 'sudo -E apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"',
        environment => "DEBIAN_FRONTEND=noninteractive"
    }
}

class { 'setup': }

#Setup repositories
class { 'apt':
  always_apt_update => true,
}


#Install default applications
case $::operatingsystem {
  default: { $default_packages = ['tree','zip','unzip','subversion','wget','ant','ant-contrib','python-setuptools', 'phpmyadmin'] }
}

package { $default_packages:
  ensure  => latest,
  require  => Exec['update'],
}

#Setup services
class { 'ufw': }

class { 'ssh::client': }
ufw::allow { 'allow-ssh-from-all':
  port => 22,
}

class { 'ntp': }
ufw::allow { 'allow-ntp-from-all':
  port => 123,
}

case $::operatingsystem {
  default: { $project_packages = ['php5-cli','php-pear','php5-mysql','php5-gd'] }
}

package { $project_packages:
  ensure   => latest,
  require  => Exec['update'],
}

class { 'apache': 
  user => 'vagrant',
  group => 'vagrant',
}
class { 'apache::php': }

class { 'mysql': }
class { 'mysql::server':
  config_hash => { 'root_password' => 'vagrant' }
}

#file { '/vagrant/drupal-data':
#  ensure => directory,
#  owner  => 'www-data',
#  group  => 'www-data',
#  mode   => '0777',
#}

#exec { 'download-drupal':
#  command => "wget http://ftp.drupal.org/files/projects/drupal-$drupal_version.zip -O /vagrant/drupal-$drupal_version.zip",
#  creates => "/vagrant/drupal-$drupal_version.zip",
#  require => Package[$default_packages],
#}

#exec { 'unzip-drupal-zip':
#  command => "unzip /vagrant/drupal-$drupal_version.zip  -d /home/vagrant",
#  creates => "/vagrant/drupal-$drupal_version",
#  require => Exec['download-drupal'],
#}

file { "/vagrant/drupal-$drupal_version":
  ensure  => directory,
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  mode    => '0777',
#  require => Exec['unzip-drupal-zip'],
}

file { '/home/vagrant/drupal-www':
  ensure  => link,
  target  => "/vagrant/drupal-$drupal_version",
#  require => File["/vagrant/drupal-$drupal_version"],
}

apache::vhost { 'drupal.test':
  priority           => '20',
  port               => '80',
  docroot            => '/home/vagrant/drupal-www',
  configure_firewall => false,
#  require            => [Exec['unzip-drupal-zip'],File['/vagrant/drupal-data']],
}
ufw::allow { 'allow-http-from-all':
  port => 80,
}

mysql::db { 'drupal':
  user     => 'drupal',
  password => 'drupal',
  host     => 'localhost',
  grant    => ['all'],
  require  => Class['mysql::server'],
}
