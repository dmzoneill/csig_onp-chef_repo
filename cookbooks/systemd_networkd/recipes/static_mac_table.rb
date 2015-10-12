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
directory "#{outdir}/network" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

### Create .network files for each enabled port ###
node[ "SystemdNetworkd" ][ "PortId" ].each do |port|
  fdb_enabled = false

  if node.include?( "SystemdNetworkd" )
    if node[ "SystemdNetworkd" ].include?( "Ports" )
      if node[ "SystemdNetworkd" ][ "Ports" ].include?( port )
        if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "Enabled" )
          if node[ "SystemdNetworkd" ][ "Ports" ][ port ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true 
            if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "FDB" )
              fdb_enabled = true
 
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
        end
      end
    end
  end
end
