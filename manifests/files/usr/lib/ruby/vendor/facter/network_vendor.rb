# Fact: network
#
# Purpose:
# Get IP, network and netmask information for available network
# interfacs.
#
# Resolution:
#  Uses 'facter/util/ip' to enumerate interfaces and return their information.
#
# Caveats:
#

Facter.add(:network_gateway) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    Facter::Util::Resolution.exec('arp -a `route -n | tail -n +3 | tr -s " " | cut -f2 -d " " | grep -v 0.0.0.0` |  tr -s " " | cut -f4 -d " "')
  end
end
