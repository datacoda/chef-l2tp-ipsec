include_recipe 'apt'
include_recipe 'firewall'
include_recipe 'monit-ng::default'

include_recipe 'l2tp-ipsec::default'
include_recipe 'l2tp-ipsec::firewall'
include_recipe 'l2tp-ipsec::monit'
