node default {
  include facter
  include apt_transport
}

class facter {
  file {"/usr/lib/ruby/vendor_ruby/facter/":
    owner   => root,
    mode    => '644',
    recurse => true,
    source  => "/etc/puppet/manifests/files/usr/lib/ruby/vendor_ruby/facter/",
  }
}

class apt_transport {
  Package {"apt-transport-https":
    ensure => installed,
  }
}
