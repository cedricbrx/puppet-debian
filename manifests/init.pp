node default {
  include facter
  include apt
}

class facter{
  file {"/usr/lib/ruby/vendor_ruby/facter/":
    owner => root,
    mode => '644',
    recurse => true,
}

class apt {
  Package {"apt-transport-https":
    ensure => installed,
  }
}
