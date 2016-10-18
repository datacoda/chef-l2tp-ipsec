#
# Cookbook Name:: l2tp-ipsec
# Attributes:: default
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

default['l2tp-ipsec']['public_interface'] = 'eth0'
default['l2tp-ipsec']['private_interface'] = 'eth0'

Chef::Log.debug "Looking for public interface #{node['l2tp-ipsec']['public_interface']}"
Chef::Log.debug "Looking for private interface #{node['l2tp-ipsec']['private_interface']}"

def filter_global_addresses(addresses)
  addresses.map do |idata|
    idata['addresses'].select do |_, info|
      info['family'] == 'inet' && info['scope'] == 'Global'
    end.keys
  end.flatten.first
end

# Performs a search through all interfaces, looking for Global addresses.
# It allows for multi-address interfaces.
public_ip = filter_global_addresses(
  node['network']['interfaces'].select do |iface, _|
    iface =~ /#{node['l2tp-ipsec']['public_interface']}(:[0-9]+)?/
  end.values
)

private_ip = filter_global_addresses(
  node['network']['interfaces'].select do |iface, _|
    iface =~ /#{node['l2tp-ipsec']['private_interface']}(:[0-9]+)?/
  end.values
)

default['l2tp-ipsec']['public_ip'] = public_ip
Chef::Log.info "Using public IP #{public_ip} for l2tp-ipsec"

default['l2tp-ipsec']['private_ip'] = private_ip
Chef::Log.info "Using private IP #{private_ip} for l2tp-ipsec"

default['l2tp-ipsec']['users'] = []

default['l2tp-ipsec']['virtual_ip_range'] = '10.55.55.5-10.55.55.100'
default['l2tp-ipsec']['virtual_interface_ip'] = '10.55.55.4'
default['l2tp-ipsec']['ppp_link_network'] = '10.55.55.0/24'
default['l2tp-ipsec']['dns_servers'] = ['8.8.8.8', '8.8.4.4']

default['l2tp-ipsec']['preshared_key'] = 'preshared_secret'

default['l2tp-ipsec']['xl2tpd_path'] = '/etc/xl2tpd'
default['l2tp-ipsec']['ppp_path'] = '/etc/ppp'
default['l2tp-ipsec']['pppoptfile'] = File.join(node['l2tp-ipsec']['ppp_path'], 'options.xl2tpd')
