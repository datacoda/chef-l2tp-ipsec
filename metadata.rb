name             'l2tp-ipsec'
maintainer       'Nephila Graphic'
maintainer_email 'ted@nephilagraphic.com'
license          'Apache 2.0'
description      'Installs/Configures l2tp-ipsec'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'

supports 'ubuntu'

suggests 'debnetwork'
recommends 'monit-ng'