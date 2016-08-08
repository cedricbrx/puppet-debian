# Fact: installed_user

Facter.add(:installed_user) do
  setcode { Facter::Core::Execution.exec('grep 1000 /etc/passwd | cut -f1 -d":"') }
end
