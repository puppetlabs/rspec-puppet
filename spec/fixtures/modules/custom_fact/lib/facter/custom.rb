Facter.add(:custom) do
  setcode { Facter.value(:myfact) ? 'foo' : 'bar' }
end
