#
# Cookbook Name:: l2tp-ipsec
# Attributes:: default
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


default['l2tp-ipsec']['public_interface'] = 'eth0'
default['l2tp-ipsec']['private_interface'] = 'eth0'


node['network']['interfaces'][ node['l2tp-ipsec']['public_interface'] ]['addresses'].each do |addr, info|
  if info['family'] == 'inet'
    default['l2tp-ipsec']['public_ip'] = addr
  end
end

node['network']['interfaces'][ node['l2tp-ipsec']['private_interface'] ]['addresses'].each do |addr, info|
  if info['family'] == 'inet'
    default['l2tp-ipsec']['private_ip'] = addr
  end
end

default['l2tp-ipsec']['users'] = []

default['l2tp-ipsec']['virtual_ip_range'] = '10.55.55.5-10.55.55.100'
default['l2tp-ipsec']['virtual_interface_ip'] = '10.55.55.4'
default['l2tp-ipsec']['ppp_link_network'] = '10.55.55.0/24'
default['l2tp-ipsec']['dns_servers'] = [ '8.8.8.8', '8.8.4.4' ]

default['l2tp-ipsec']['preshared_key'] = 'preshared_secret'

default['l2tp-ipsec']['xl2tpd_path'] = '/etc/xl2tpd'
default['l2tp-ipsec']['ppp_path'] = '/etc/ppp'
default['l2tp-ipsec']['pppoptfile'] = File.join(node['l2tp-ipsec']['ppp_path'], "options.xl2tpd")

