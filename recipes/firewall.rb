#
# Cookbook Name:: l2tp-ipsec
# Recipe:: firewall
#
# Copyright 2014-2016 Nephila Graphic, Li-Te Chen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'firewall'

firewall 'iptables' do
  action :install
end

# loopback (required for monit)
firewall_rule 'loopback' do
  interface 'lo'
  destination '127.0.0.1'
  command :allow
  position 20
end

firewall_rule 'IKEv1' do
  port 500
  protocol :udp
  destination '0.0.0.0/0'
  command :allow
end

# required for the initial connect
firewall_rule 'l2tp' do
  port 1701
  protocol :udp
  destination '0.0.0.0/0'
  command :allow
end

firewall_rule 'ipsec-nat-t' do
  port 4500
  protocol :udp
  destination '0.0.0.0/0'
  command :allow
end

# The setup for Ubuntu 14.04 has changed somewhat.
firewall_rule '12.x packet-routing' do
  raw "-A POSTROUTING -s #{node['l2tp-ipsec']['ppp_link_network']} -o #{node['l2tp-ipsec']['private_interface']} -j MASQUERADE"
  position 105
  only_if { node['platform_version'].include?('12.') }
end

firewall_rule '14.x packet-routing' do
  raw "-A POSTROUTING -j SNAT --to-source #{node['l2tp-ipsec']['public_ip']} -o #{node['l2tp-ipsec']['private_interface']}"
  position 105
  only_if { node['platform_version'].include?('14.') }
end

# Allow IPSEC authentication using ESP protocol
# see https://wiki.gentoo.org/wiki/IPsec_L2TP_VPN_server
firewall_rule 'esp_in' do
  protocol 50
  command :allow
end

firewall_rule 'esp_out' do
  direction :out
  protocol 50
  command :allow
end

firewall_rule 'ah_in' do
  protocol 51
  command :allow
end

firewall_rule 'ah_out' do
  direction :out
  protocol 51
  command :allow
end

# Block all L2TP connections outside the ipsec layer
firewall_rule 'input_l2tp_ipsec_allow' do
  raw '-A INPUT -p udp -m policy --dir in --pol ipsec -m udp --dport l2tp -j ACCEPT'
end

firewall_rule 'input_l2tp_ipsec_block' do
  raw '-A INPUT -p udp -m udp --dport l2tp -j REJECT --reject-with icmp-port-unreachable'
end

firewall_rule 'output_l2tp_ipsec_allow' do
  raw '-A OUTPUT -p udp -m policy --dir out --pol ipsec -m udp --sport l2tp -j ACCEPT'
end

firewall_rule 'output_l2tp_ipsec_block' do
  raw '-A OUTPUT -p udp -m udp --sport l2tp -j REJECT --reject-with icmp-port-unreachable'
end

# Forward packets between the ppp and the external interface
firewall_rule 'forward_established_connection' do
  raw "-A FORWARD -i #{node['l2tp-ipsec']['private_interface']} -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT"
end

firewall_rule 'forward_established_ppp' do
  raw '-A FORWARD -i ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT'
end

firewall_rule 'forward_ppp_out' do
  raw "-A FORWARD -i ppp+ -o #{node['l2tp-ipsec']['private_interface']} -j ACCEPT"
end

# Send redirects aren't normally in the sysctl file.  We'll need to pull
# up all the interfaces
send_redirects_rules = []
send_redirects_value = 0

Dir['/proc/sys/net/ipv4/conf/*/send_redirects'].each do |interface|
  interface.sub!(%r{/proc/sys/}, '')
  send_redirects_rules << "#{interface}=#{send_redirects_value}"
end

template '/etc/sysctl.d/20-firewall.conf' do
  source 'sysctl.conf.erb'
  mode '0644'
  variables(
    is_openvz_ve: false,
    ipv4_forward: true,
    ipv6_forward: false,
    accept_redirects: false,
    send_redirects_rules: send_redirects_rules
  )
  notifies :restart, 'service[procps]'
end

service 'procps' do
  action :nothing
end
