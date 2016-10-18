#
# Cookbook Name:: l2tp-ipsec
# Recipe:: monit
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

directory '/etc/monit/scripts' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template '/etc/monit/scripts/ipsec_status.sh' do
  source 'monit/ipsec_status.sh.erb'
  user 'root'
  group 'root'
  mode '0755'
end

monit_check 'ipsec' do
  check_type 'program'
  check_id '/etc/monit/scripts/ipsec_status.sh'
  tests [
    {
      'condition' => 'status != 0',
      'action'    => 'exec "/etc/init.d/ipsec restart"'
    },
    {
      'condition' => '5 restarts within 5 cycles',
      'action'    => 'timeout'
    }
  ]
end

monit_check 'xl2tpd' do
  check_id '/var/run/xl2tpd.pid'
  group 'app'
  start '/etc/init.d/xl2tpd start'
  stop '/etc/init.d/xl2tpd stop'
  tests [
    {
      'condition' => '5 restarts within 5 cycles',
      'action'    => 'timeout'
    }
  ]
end
