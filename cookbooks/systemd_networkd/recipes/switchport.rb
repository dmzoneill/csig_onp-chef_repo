# frozen_string_literal: true

#
# Cookbook Name:: systemd_networkd
# Recipe:: switchport
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node['SystemdNetworkd']['outdir']

### Create network/switchport directory if necessary ###
ensure_networkd_subdir('switchport')

# create .swport files for each enabled port
node['SystemdNetworkd']['PortId'].each do |port|
  settings = port_settings(port)
  next unless settings

  has_switch_config = settings.include?('Attributes') ||
                      settings.include?('QOS') ||
                      settings.include?('RateLimit')
  next unless port_or_backup?(port) && has_switch_config

  template "#{outdir}/switchport/#{port}.swport" do
    source 'switchport/switchport.erb'
    variables({
                DevName: port
              })
    mode 0o644
    owner 'systemd-network'
    group 'systemd-network'
    action :create
    notifies :restart, 'service[systemd-networkd]', :delayed
  end

  ### Create symlinks ###
  link "#{outdir}/#{port}.swport" do
    to "#{outdir}/switchport/#{port}.swport"
  end
end
