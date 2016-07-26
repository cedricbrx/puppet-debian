# Fact: wireless_vendor

Facter.add(:wireless_vendor) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    Facter::Util::Resolution.exec('lspci | grep -i "Network Controller" | tr -s " " | tr "[:upper:]" "[:lower:]" | cut -f4 -d " " | uniq')
  end
end
