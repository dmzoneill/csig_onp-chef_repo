#
# Cookbook Name:: systemd_networkd
# Recipe:: static_mac_table
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/network directory if necessary ###
ensure_networkd_subdir( "network" )

### Create .network files for each enabled port ###
node[ "SystemdNetworkd" ][ "PortId" ].each do |port|
  settings = port_settings( port )
  if port_or_backup?( port ) && settings.include?( "FDB" )
    template "#{outdir}/network/#{port}.network" do
      source "static_mac_table/static_mac_table.erb"
      variables({
        :DevName => port
      })
      mode 0644
      owner "systemd-network"
      group "systemd-network"
      action :create
      notifies :restart, "service[systemd-networkd]", :delayed
    end

    ### Create symlinks ###
    link "#{outdir}/#{port}.network" do
      to "#{outdir}/network/#{port}.network"
    end
  end
end
