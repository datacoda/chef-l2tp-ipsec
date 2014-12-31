#
# Cookbook Name:: l2tp-ipsec
# Recipe:: firewall
#
# Copyright (C) 2014 Nephila Graphic
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

firewall_rule 'IKEv1' do
  port 500
  protocol :udp
  destination '0.0.0.0/0'
  action :allow
end

# required for the initial connect
firewall_rule 'l2tp' do
  port 1701
  protocol :udp
  destination '0.0.0.0/0'
  action :allow
end

firewall_rule 'ipsec-nat-t' do
  port 4500
  protocol :udp
  destination '0.0.0.0/0'
  action :allow
end

# The setup for Ubuntu 14.04 has changed somewhat.
if node['platform_version'].include?('12.')
  packet_routing = "-s #{node['l2tp-ipsec']['ppp_link_network']} -o #{node['l2tp-ipsec']['private_interface']} -j MASQUERADE"
elsif node['platform_version'].include?('14.')
  packet_routing = "-j SNAT --to-source #{node['l2tp-ipsec']['public_ip']} -o #{node['l2tp-ipsec']['private_interface']}"
end

firewall_ex 'ufw' do
  ipv4_forward true

  # Disable send_redirects to keep openswan from complaining
  # http://riobard.com/2010/04/30/l2tp-over-ipsec-ubuntu/
  accept_redirects false
  send_redirects false

  # Allow IPSEC authentication using ESP protocol
  # see https://wiki.gentoo.org/wiki/IPsec_L2TP_VPN_server
  input '-p esp -j ACCEPT'
  output '-p esp -j ACCEPT'

  # Forward traffic from the ppp to the outbound link.
  postrouting packet_routing

  # Forward packets between the ppp and the external interface
  forward "-i #{node['l2tp-ipsec']['private_interface']} -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT"
  forward '-i ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT'
  forward "-i ppp+ -o #{node['l2tp-ipsec']['private_interface']} -j ACCEPT"

  action :enable
end
