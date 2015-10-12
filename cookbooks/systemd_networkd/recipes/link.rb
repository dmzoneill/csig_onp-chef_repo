#
# Cookbook Name:: systemd_networkd
# Recipe:: link
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/link directory if necessary ###
directory "#{outdir}/link" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

directory "#{outdir}/network" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

### Create .link and .network files for each enabled port ###
node[ "SystemdNetworkd" ][ "PortId" ].each do |port|
  if node.include?( "SystemdNetworkd" )
    if node[ "SystemdNetworkd" ].include?( "Ports" )
      if node[ "SystemdNetworkd" ][ "Ports" ].include?( port )
        if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "Enabled" ) 
          if node[ "SystemdNetworkd" ][ "Ports" ][ port ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true 

            PhysPortID = port.scan(/\d+/).last

            template "#{outdir}/link/00-#{port}.link" do
              source "link/link.erb"
              variables({
                :DevName => port,
                :PhysPortID => PhysPortID
              })
              mode 0644
              owner "systemd-network"
              group "systemd-network"
              action :create
            end

            template "#{outdir}/network/#{port}.network" do
              source "link/network.erb"
              variables({
                :DevName => port,
              })
              mode 0644
              owner "systemd-network"
              group "systemd-network"
              action :create_if_missing
              notifies :run, "execute[udevadm-trigger-net-add]", :delayed
              notifies :restart, "service[systemd-networkd]", :delayed
            end
          
            link "#{outdir}/#{port}.network" do
              to "#{outdir}/network/#{port}.network"
            end

          end

          ### Create symlinks ###
          link "#{outdir}/00-#{port}.link" do
            to "#{outdir}/link/00-#{port}.link"
            only_if { node[ "SystemdNetworkd" ][ "Ports" ][ port ][ "Enabled" ] == true }
          end

        end
      end
    end
  end
end

