l2tp-ipsec cookbook
===================

Cookbook to create a L2TP/IPSEC VPN


Requirements
------------

Recommended cookbooks:
 - `firewall`
 - `monit`


Usage
-----

Attributes
----------


Recipes
-------

### default
Just calls install.

### install
Installs the packages and configures it.  This does not include any iptable management.

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
Uses the UFW firewall and opens the required ports.  Also adds postrouting to the iptables.

### monit
Configures monit to watch the ipsec and xl2tpd services.


License & Authors
-----------------
- Author:: Ted Chen (<ted@nephilagraphic.com>)

```text
Copyright 2014, Nephila Graphic

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