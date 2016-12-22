require 'spec_helper'

# Ensure the packages are installed
%w(ppp xl2tpd openswan).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('xl2tpd') do
  it { should be_enabled }
  it { should be_running }
  it { should be_monitored_by('monit') }
end

describe service('ufw') do
  it { should be_enabled }
  it { should be_running }
end

describe service('ipsec') do
  it { should be_enabled }
  it { should be_running }
end

# Ensure network is setup properly
# References:
#  https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_12.04.html
#  http://riobard.com/2010/04/30/l2tp-over-ipsec-ubuntu/
describe 'Linux kernel parameters' do
  context linux_kernel_parameter('net.ipv4.ip_forward') do
    its(:value) { should eq 1 }
  end

  context linux_kernel_parameter('net.ipv4.conf.all.accept_redirects') do
    its(:value) { should eq 0 }
  end

  %w(all eth0 eth1).each do |interface|
    context linux_kernel_parameter("net.ipv4.conf.#{interface}.send_redirects") do
      its(:value) { should eq 0 }
    end
  end
end

# Check ports
describe port(500) do
  it { should be_listening.with('udp') }
end

describe port(1701) do
  it { should be_listening.with('udp') }
end

describe port(4500) do
  it { should be_listening.with('udp') }
end

describe port(80) do
  it { should_not be_listening.with('tcp') }
end

# Check file security
%w(/etc/ppp/pap-secrets /etc/xl2tpd/l2tp-secrets /etc/ipsec.secrets).each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should_not be_readable.by('others') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable.by('others') }
  end
end

# Check that test users are created
describe file('/etc/ppp/pap-secrets') do
  # format *       l2tpd           ""              *
  its(:content) { should match(/\*\s+l2tpd\s+""\s+\*/) }
end

describe file('/etc/iptables/rules.v4') do
  its(:content) { should match(/-A INPUT -p (esp|50) .*-j ACCEPT/) }
  its(:content) { should match(/-A OUTPUT -p (esp|50) .*-j ACCEPT/) }

  its(:content) { should match(/-A INPUT -p (ah|51) .*-j ACCEPT/) }
  its(:content) { should match(/-A OUTPUT -p (ah|51) .*-j ACCEPT/) }

  its(:content) { should match(/-o ppp\+ -m state --state RELATED,ESTABLISHED -j ACCEPT/) }
  its(:content) { should match(/-i ppp\+ -m state --state RELATED,ESTABLISHED -j ACCEPT/) }
end

describe file('/etc/sysctl.d/99-chef-attributes.conf') do
  its(:content) { should match %r{net/ipv4/conf/all/accept_redirects=0} }
  its(:content) { should match %r{net/ipv4/conf/all/send_redirects=0} }
end

describe file('/etc/ppp/options.xl2tpd') do
  its(:content) { should match(/login/) }
  its(:content) { should_not match(/require-mschap-v2/) }
end

describe file('/etc/xl2tpd/xl2tpd.conf') do
  its(:content) { should match(/unix authentication\s+=\s+yes/) }
  its(:content) { should_not match(/refuse pap\s+=\s+yes/) }
end
