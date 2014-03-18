require 'serverspec'
require 'spec_helper'

include Serverspec::Helper::Exec

# Ensure the packages are installed
%w{ppp xl2tpd openswan}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('xl2tpd') do
  it { should be_enabled }
  it { should be_running }
  it { should be_monitored_by('monit') }
end

describe service('ipsec') do
  it { should be_enabled }
  it { should be_running }
end


# Ensure network is setup properly
# References:
#  https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_12.04.html
#  http://riobard.com/2010/04/30/l2tp-over-ipsec-ubuntu/

describe file('/proc/sys/net/ipv4/ip_forward') do
  it { should contain '1' }
end

describe file('/proc/sys/net/ipv4/conf/all/accept_redirects') do
  it { should contain '0' }
end

%w{all eth0 eth1}.each do |interface|
  describe file("/proc/sys/net/ipv4/conf/#{interface}/send_redirects") do
    it { should contain '0' }
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


# Check password security
%w{/etc/ppp/chap-secrets /etc/xl2tpd/l2tp-secrets /etc/ipsec.secrets}.each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should_not be_readable.by('others') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable.by('others') }
  end
end