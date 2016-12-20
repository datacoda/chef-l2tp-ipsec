#
# Cookbook Name:: l2tp-ipsec
# Recipe:: install
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

%w(lsof ppp xl2tpd openswan).each do |p|
  package p
end

# Service definitions
#
service 'xl2tpd' do
  supports restart: true,
           start: true,
           stop: true
  action :enable
end

service 'ipsec' do
  supports status: true,
           restart: true,
           reload: true,
           start: true,
           stop: true
  action :enable
end

# Create configuration files for Ubuntu 12.04
# References:
#  https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_12.04.html
#  http://riobard.com/2010/04/30/l2tp-over-ipsec-ubuntu/

template '/etc/ipsec.conf' do
  source 'ipsec.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'

  variables(
    virtual_private: node['l2tp-ipsec']['virtual_private'],
    ppp_link_network: node['l2tp-ipsec']['ppp_link_network'],
    public_ip: node['l2tp-ipsec']['public_ip'],
    private_ip: node['l2tp-ipsec']['private_ip']
  )

  notifies :restart, 'service[ipsec]'
end

template '/etc/ipsec.secrets' do
  source 'ipsec.secrets.erb'
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true

  variables(
    public_ip: node['l2tp-ipsec']['public_ip'],
    preshared_key: node['l2tp-ipsec']['preshared_key']
  )
  notifies :restart, 'service[ipsec]'
end

template "#{node['l2tp-ipsec']['ppp_path']}/chap-secrets" do
  source 'chap-secrets.erb'
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true

  variables(
    users: node['l2tp-ipsec']['users']
  )
  notifies :restart, 'service[xl2tpd]'
  notifies :restart, 'service[ipsec]'
end

template "#{node['l2tp-ipsec']['xl2tpd_path']}/xl2tpd.conf" do
  source 'xl2tpd.conf.erb'
  variables(
    virtual_ip_range: node['l2tp-ipsec']['virtual_ip_range'],
    virtual_interface_ip: node['l2tp-ipsec']['virtual_interface_ip'],
    pppoptfile: node['l2tp-ipsec']['pppoptfile']
  )
  notifies :restart, 'service[xl2tpd]'
end

template node['l2tp-ipsec']['pppoptfile'] do
  source 'options.xl2tpd.erb'
  variables(
    dns_servers: node['l2tp-ipsec']['dns_servers']
  )
  notifies :restart, 'service[xl2tpd]'
end
