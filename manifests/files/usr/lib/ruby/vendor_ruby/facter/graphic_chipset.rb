# Fact: graphic_chipset

Facter.add(:graphic_chipset) do
  confine :kernel => [ :linux, :"gnu/kfreebsd" ]
  setcode do
    Facter::Util::Resolution.exec('lspci | grep -i "VGA compatible controller" | tr -s " " | tr "[:upper:]" "[:lower:]" | grep -v "aspeed" | cut -f7 -d " " | uniq')
  end
end
