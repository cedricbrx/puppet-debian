# Fact: network

Facter.add(:network_vendor) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    Facter::Util::Resolution.exec('sudo lshw | grep -i -n2 "display" | grep -E '[A-Z]{2}[0-9]{3}' | tr -s " " | tr '[:upper:]' '[:lower:]' | cut -f3 -d " " | uniq')
  end
end
