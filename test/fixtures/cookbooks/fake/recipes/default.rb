include_recipe 'apt'
include_recipe 'firewall-ex'
include_recipe 'monit-ng::default'

# open standard ssh port, enable firewall
firewall_rule 'ssh' do
  port 22
  action :allow
end

include_recipe 'l2tp-ipsec::default'
include_recipe 'l2tp-ipsec::firewall'
include_recipe 'l2tp-ipsec::monit'
