include_recipe 'monit-ng::default'

# open standard ssh port, enable firewall
firewall_rule 'ssh' do
  port     22
  action   :allow
  notifies :enable, 'firewall[ufw]'
end

firewall 'ufw' do
  action :nothing
end

include_recipe 'l2tp-ipsec::default'

include_recipe 'l2tp-ipsec::firewall'

include_recipe 'l2tp-ipsec::monit'