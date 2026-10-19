# frozen_string_literal: true

#
# Cookbook Name:: systemd_networkd_ufd
# Recipe:: default
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node['SystemdNetworkd']['outdir']

### Create network/ufd directory if necessary ###
ensure_networkd_subdir('ufd')

### Create .netdev files for each ufd enable ###
if node.include?('SystemdNetworkd') && node['SystemdNetworkd'].include?('UFD')
  node['SystemdNetworkd']['UFD'].each do |ufd_carrier, ufd_settings|
    record = node['SystemdNetworkd']['UFD'][ufd_carrier]
    backup = node['SystemdNetworkd']['Backup'] == true
    next unless record.include?('Enabled') && (record['Enabled'] == true || backup)

    template "#{outdir}/ufd/ufd_#{ufd_carrier}.network" do
      source 'ufd/ufd.erb'
      variables({
                  Carrier: ufd_carrier,
                  BindCarrier: ufd_settings['BindCarrier']
                })
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create
      notifies :restart, 'service[systemd-networkd]', :delayed
    end

    ### Create symlinks ###
    link "#{outdir}/ufd_#{ufd_carrier}.network" do
      to "#{outdir}/ufd/ufd_#{ufd_carrier}.network"
    end
  end
end
