node default {
  include facter
  include apt-transport
}

class facter {
  file {"/usr/lib/ruby/vendor_ruby/facter/":
    owner => root,
    mode => '644',
    recurse => true,
  }
}

class apt-transport {
  Package {"apt-transport-https":
    ensure => installed,
  }
}
