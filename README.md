l2tp-ipsec cookbook
===================
[![Cookbook Version](https://img.shields.io/cookbook/v/l2tp-ipsec.svg)](https://supermarket.chef.io/cookbooks/l2tp-ipsec)
[![Dependency Status](http://img.shields.io/gemnasium/datacoda/chef-l2tp-ipsec.svg?style=flat)](https://gemnasium.com/datacoda/chef-l2tp-ipsec)
[![Build Status](https://travis-ci.org/datacoda/chef-l2tp-ipsec.svg?branch=master)](https://travis-ci.org/datacoda/chef-l2tp-ipsec)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

Cookbook to create a L2TP/IPSEC VPN.  It installs

- `openswan` - For IPSEC.
- `xl2tpd` - For l2tpd.
- `firewall` - Sets up iptables for port forwarding, etc
- `sysctl` - Sets up nic forwarding.
- `monit-ng` - For l2tp-ipsec::monit recipe.

Requirements
------------

This VPN server requires full virtualization like KVM or XEN.  It does not work under OpenVZ.


Usage
-----

1. If you have a unique setup of net interfaces, override private_interface and public_interface as need be.

2. Set the attribute `preshared_key`

3. To add users, fill the node attribute `users`.  It accepts an array of users

     # [ { username: bob, vpn_password: mypass } ]


Attributes
----------


Recipes
-------

### default
Just calls install.

### install
Installs the packages and configures it.  This does not include any iptable or send_redirects management.

To complete the installation, either include the firewall recipe or add your own masquerade routing.

```
# nat Table rules
*nat
:POSTROUTING ACCEPT [0:0]

# Forward traffic from the ppp to the outbound link.
-F POSTROUTING
-A POSTROUTING -s <%= @ppp_link_network %> -o <%= @private_interface %> -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't be processed
COMMIT

*filter
# Forward packets between the ppp and the external interface
-A -i <%= @private_interface %> -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT
-A -i ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT
-A -i ppp+ -o <%= @private_interface %> -j ACCEPT

```

### firewall
Uses the iptables to open the required ports.  Also adds postrouting to the iptables. Also turns off redirects, etc according to

https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_12.04.html
https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_14.04.html

### monit
Configures monit to watch the ipsec and xl2tpd services.


License & Authors
-----------------
- Author:: Li-Te Chen (<datacoda@gmail.com>)

```text
Copyright 2014-2016 Nephila Graphic, Li-Te Chen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
