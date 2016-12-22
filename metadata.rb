name 'l2tp-ipsec'
maintainer 'Li-Te Chen'
maintainer_email 'datacoda@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures l2tp-ipsec'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'
source_url 'https://github.com/datacoda/chef-l2tp-ipsec'
issues_url 'https://github.com/datacoda/chef-l2tp-ipsec/issues'

supports 'ubuntu'

# Required if you use the l2tp-ipsec::firewall recipe
# to enable port forwarding.
depends 'firewall'
depends 'sysctl'

# Required if you use the l2tp-ipsec::monit recipe
depends 'monit-ng'
