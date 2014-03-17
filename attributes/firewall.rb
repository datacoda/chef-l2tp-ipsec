#
# Cookbook Name:: l2tp-ipsec
# Attributes:: firewall
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

include_attribute 'l2tp-ipsec::default'


# Disable send_redirects
override['debnetwork']['send_redirects']['action'] = 'disable'


# Forward traffic from the ppp to the outbound link.
override['debnetwork']['postrouting_rules'] = [
    "-s #{node['l2tp-ipsec']['ppp_link_network']} -o #{node['l2tp-ipsec']['private_interface']} -j MASQUERADE"
]


# Forward packets between the ppp and the external interface
override['debnetwork']['forward_rules'] = [
    "-i #{node['l2tp-ipsec']['private_interface']} -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT",
    "-i ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT",
    "-i ppp+ -o #{node['l2tp-ipsec']['private_interface']} -j ACCEPT"
]
