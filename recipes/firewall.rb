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



include_recipe 'debnetwork::default'


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


firewall 'ufw' do
  action :nothing
end