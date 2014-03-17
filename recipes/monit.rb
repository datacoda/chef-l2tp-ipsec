#
# Cookbook Name:: l2tp-ipsec
# Recipe:: monit
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

directory '/etc/monit/scripts' do
  owner   'root'
  group   'root'
  mode    00755
  action  :create
end

template '/etc/monit/scripts/ipsec_status.sh' do
  source  'monit/ipsec_status.sh.erb'
  user    'root'
  group   'root'
  mode    00755
end

monitrc 'ipsec' do
  template_source 'monit/ipsec.conf.erb'
  template_cookbook 'l2tp-ipsec'
end

monitrc 'xl2tpd' do
  template_source 'monit/xl2tpd.conf.erb'
  template_cookbook 'l2tp-ipsec'
end

