require 'spec_helper'

describe 'fake::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      platform: 'ubuntu',
      version: '14.04'
    ) do |node|
      node.set['virtualization']['system'] = 'openvz'
      node.set['l2tp-ipsec']['users'] = [
        { username: 'bob', vpn_password: 'bobsecret' },
        { username: 'alice', vpn_password: 'alicesecret' }
      ]
    end.converge('fake::default')
  end

  it 'has firewall' do
    expect(chef_run).to install_firewall('iptables')
    expect(chef_run).to create_firewall_rule('loopback')
    expect(chef_run).to create_firewall_rule('IKEv1')
    expect(chef_run).to create_firewall_rule('l2tp')
    expect(chef_run).to create_firewall_rule('ipsec-nat-t')
  end

  it 'has ipsec' do
    expect(chef_run).to install_package('openswan')
    expect(chef_run).to enable_service('ipsec')
    expect(chef_run).to create_monit_check('ipsec')
    expect(chef_run).to create_template('/etc/ipsec.conf')
    expect(chef_run).to create_template('/etc/ipsec.secrets')
  end

  it 'has ppp' do
    expect(chef_run).to install_package('ppp')
    expect(chef_run).to create_template('/etc/ppp/chap-secrets')
    expect(chef_run).to create_template('/etc/ppp/options.xl2tpd')
  end

  it 'has xl2tpd' do
    expect(chef_run).to install_package('xl2tpd')
    expect(chef_run).to enable_service('xl2tpd')
    expect(chef_run).to create_monit_check('xl2tpd')
    expect(chef_run).to create_template('/etc/xl2tpd/xl2tpd.conf')
  end

  it 'has monitoring' do
    expect(chef_run).to install_package('monit')
    expect(chef_run).to enable_service('monit')
    expect(chef_run).to create_directory('/etc/monit/conf.d')
    expect(chef_run).to create_template('/etc/monit/monitrc')
  end

  it 'has custom ipsec monitoring scripts' do
    expect(chef_run).to create_directory('/etc/monit/scripts')
    expect(chef_run).to create_template('/etc/monit/scripts/ipsec_status.sh')
  end
end
