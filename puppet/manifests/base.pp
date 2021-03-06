Exec {
    path => "/usr/sbin:/usr/bin:/sbin:/bin",
}

import "apache2.pp"
import "php.pp"
import "phpunit.pp"

group { "puppet":
  ensure => "present",
}
File { owner => 0, group => 0, mode => 0644 }

file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
    Managed by Puppet.\n"
}

file { '/var/www/application/cache':
  ensure => directory,
  owner  => root,
  group  => www-data,
  mode   => '0775',
}

file { '/var/www/application/logs':
  ensure => directory,
  owner  => root,
  group  => www-data,
  mode   => '0775',
}

file { '/var/www/application/media/uploads':
  ensure => directory,
  owner  => root,
  group  => www-data,
  mode   => '0775',
}

exec { "apt-get_update":
    command     => "/usr/bin/apt-get update",
    require     => [ File["norecommends"],
                     File["defaultrelease"],
                   ],
    tries       => 3
}

exec { "apt-get_upgrade":
    command     => "/usr/bin/apt-get -y upgrade",
    require     => [ Exec["apt-get_update"] ],
    tries       => 3,
    refreshonly => true
}

file { "norecommends":
    path    => "/etc/apt/apt.conf.d/02norecommends",
    content => "APT::Install-Recommends \"0\";",
}

file { "defaultrelease":
    path    => "/etc/apt/apt.conf.d/03defaultrelease",
    content => "APT::Default-Release \"saucy\";",
}

$misc_packages = [
    "mysql-client",
    "curl",
    "wget",
    "git",
    "postfix",
    "byobu",
    "nfs-common",
]

Package {
    ensure  => installed,
    require => Bulkpackage["misc-packages"],
}

bulkpackage { "misc-packages":
    packages => $misc_packages,
    require  => [ Exec["apt-get_update"],
                  Exec["apt-get_upgrade"]
                ],
}

package { $misc_packages: }

include base::apache2
include base::php
include base::phpunit
