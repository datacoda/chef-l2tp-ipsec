include_recipe 'l2tp-ipsec::default'


# open standard ssh port, enable firewall
firewall_rule 'ssh' do
  port     22
  action   :allow
  notifies :enable, 'firewall[ufw]'
end

include_recipe 'l2tp-ipsec::firewall'


firewall 'ufw' do
  action :nothing
end