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


firewall_rule 'ESP' do
  port          50
  destination   '0.0.0.0/0'
  action        :allow
  notifies      :enable, 'firewall[ufw]'
end

firewall_rule 'IKEv1' do
  port          500
  protocol      :udp
  destination   '0.0.0.0/0'
  action        :allow
  notifies      :enable, 'firewall[ufw]'
end

# required for the initial connect
firewall_rule 'l2tp' do
  port          1701
  protocol      :udp
  destination   '0.0.0.0/0'
  action        :allow
  notifies      :enable, 'firewall[ufw]'
end

firewall_rule 'ipsec-nat-t' do
  port          4500
  protocol      :udp
  destination   '0.0.0.0/0'
  action        :allow
  notifies      :enable, 'firewall[ufw]'
end

# Firewalls are slightly different for OpenVZ
is_openvz_ve = node['virtualization']['system'] == 'openvz' && node['virtualization']['role'] == 'guest'


template '/etc/ufw/before.rules' do
  source      'ufw.before.rules.erb'
  mode        00640
  variables(
      :is_openvz_ve => is_openvz_ve,
      :ppp_link_network => node['l2tp-ipsec']['ppp_link_network'],
      :private_interface => node['l2tp-ipsec']['private_interface']
  )
  notifies    :enable, 'firewall[ufw]', :delayed
end


template '/etc/ufw/sysctl.conf' do
  source      'ufw.sysctl.conf.erb'
  mode        00644
  variables(
      :is_openvz_ve => is_openvz_ve,
      :send_redirects => node['l2tp-ipsec']['send_redirects']
  )
  notifies    :enable, 'firewall[ufw]', :delayed
end

firewall 'ufw' do
  action :nothing
end