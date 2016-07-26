# Fact: network_vendor

Facter.add(:network_vendor) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    Facter::Util::Resolution.exec('lspci | grep -i "Ethernet Controller" | tr -s " " | tr "[:upper:]" "[:lower:]" | cut -f4 -d " " | uniq')
  end
end
