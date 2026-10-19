# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

#
# Cookbook Name:: systemd_networkd
# Recipe:: link
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node['SystemdNetworkd']['outdir']

### Create network/link directory if necessary ###
ensure_networkd_subdir('link')
ensure_networkd_subdir('network')

### Create .link and .network files for each enabled port ###
node['SystemdNetworkd']['PortId'].each do |port|
  settings = port_settings(port)
  next unless settings&.include?('Enabled')

  enabled = settings['Enabled'] == true
  if enabled || systemd_networkd['Backup'] == true
    phys_port_id = port.scan(/\d+/).last

    template "#{outdir}/link/00-#{port}.link" do
      source 'link/link.erb'
      variables({
                  DevName: port,
                  PhysPortID: phys_port_id
                })
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create
    end

    template "#{outdir}/network/#{port}.network" do
      source 'link/network.erb'
      variables({
                  DevName: port
                })
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create_if_missing
      notifies :run, 'execute[udevadm-trigger-net-add]', :delayed
      notifies :restart, 'service[systemd-networkd]', :delayed
    end

    link "#{outdir}/#{port}.network" do
      to "#{outdir}/network/#{port}.network"
    end
  end

  ### Create symlinks ###
  link "#{outdir}/00-#{port}.link" do
    to "#{outdir}/link/00-#{port}.link"
    only_if { enabled }
  end
end
# rubocop:enable Metrics/BlockLength
