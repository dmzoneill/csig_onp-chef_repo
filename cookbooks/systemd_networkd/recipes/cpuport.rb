# frozen_string_literal: true

#
# Cookbook Name:: systemd_networkd
# Recipe:: cpuport
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node['SystemdNetworkd']['outdir']

### Create network/cpuport directory if necessary ###
ensure_networkd_subdir('cpuport')

cpu_port = node['SystemdNetworkd']['Ports']['sw0p0'] if node.include?('SystemdNetworkd') &&
                                                        node['SystemdNetworkd'].include?('Ports') &&
                                                        node['SystemdNetworkd']['Ports'].include?('sw0p0')
cpu_keys = %w[L2HashKey L3HashConfig Attributes RateLimit Vlans QOS]
if cpu_port && cpu_keys.any? { |key| cpu_port.include?(key) }

  template "#{outdir}/cpuport/sw0p0.swport" do
    source 'cpuport/cpuport.erb'
    mode 0o644
    owner 'systemd-network'
    group 'systemd-network'
    action :create
    notifies :restart, 'service[systemd-networkd]', :delayed
  end

  link "#{outdir}/sw0p0.swport" do
    to "#{outdir}/cpuport/sw0p0.swport"
  end

end
