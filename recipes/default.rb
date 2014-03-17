#
# Cookbook Name:: l2tp-ipsec
# Recipe:: default
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

#find_public_ip = Mixlib::ShellOut.new("ifconfig #{node['vpn-server']['public_interface']} | grep \"inet addr\" | awk 'BEGIN{FS=\":\"}{print $2}' | awk '{print $1}'")
#find_private_ip = Mixlib::ShellOut.new("ifconfig #{node['vpn-server']['private_interface']} | grep \"inet addr\" | awk 'BEGIN{FS=\":\"}{print $2}' | awk '{print $1}'")

#find_public_ip.run_command
#find_private_ip.run_command


#node.default['vpn-server']['public_ip'] = find_public_ip.stdout.strip
#node.default['vpn-server']['private_ip'] = find_private_ip.stdout.strip
#

%w(lsof ppp xl2tpd openswan).each do |p|
  package p
end

# Service definitions
#
service 'xl2tpd' do
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
end

service 'ipsec' do
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
end


template '/etc/ipsec.conf' do
  source 'ipsec.conf.erb'
  owner   'root'
  group   'root'
  mode    0644

  variables(
      :ppp_link_network => node['l2tp-ipsec']['ppp_link_network'],
      :public_ip => node['l2tp-ipsec']['public_ip'],
      :private_ip => node['l2tp-ipsec']['private_ip']
  )

  notifies :restart, 'service[ipsec]', :delayed
end


template '/etc/ipsec.secrets' do
  source  'ipsec.secrets.erb'
  owner   'root'
  group   'root'
  mode    0600

  variables(
      :public_ip => node['l2tp-ipsec']['public_ip'],
      :preshared_key => node['l2tp-ipsec']['preshared_key']
  )
  notifies :restart, 'service[ipsec]', :delayed
end


template "#{node['l2tp-ipsec']['ppp_path']}/chap-secrets" do
  source 'chap-secrets.erb'
  variables(
      :users => node['l2tp-ipsec']['users']
  )
  notifies :restart, 'service[xl2tpd]', :delayed
  notifies :restart, 'service[ipsec]', :delayed
end


template "#{node['l2tp-ipsec']['xl2tpd_path']}/xl2tpd.conf" do
  source 'xl2tpd.conf.erb'
  variables(
      :virtual_ip_range => node['l2tp-ipsec']['virtual_ip_range'],
      :virtual_interface_ip => node['l2tp-ipsec']['virtual_interface_ip'],
      :pppoptfile => node['l2tp-ipsec']['pppoptfile']
  )
  notifies :restart, 'service[xl2tpd]', :delayed
end

template node['l2tp-ipsec']['pppoptfile'] do
  source 'options.xl2tpd.erb'
  variables(
      :dns_servers => node['l2tp-ipsec']['dns_servers']
  )
  notifies :restart, 'service[xl2tpd]', :delayed
end
