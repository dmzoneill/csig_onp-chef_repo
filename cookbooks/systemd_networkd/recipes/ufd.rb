#
# Cookbook Name:: systemd_networkd_ufd
# Recipe:: default
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/ufd directory if necessary ###
directory "#{outdir}/ufd" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

### Create .netdev files for each ufd enable ###
if node.include?( "SystemdNetworkd" )
  if node[ "SystemdNetworkd" ].include?( "UFD" )
    node[ "SystemdNetworkd" ][ "UFD" ].each do |ufd_carrier,ufd_settings|
      if node[ "SystemdNetworkd" ][ "UFD" ][ ufd_carrier ].include?( "Enabled" )
        if node[ "SystemdNetworkd" ][ "UFD" ][ ufd_carrier ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true
          
            template "#{outdir}/ufd/ufd_#{ufd_carrier}.network" do
              source "ufd/ufd.erb"
              variables({
                  :Carrier => ufd_carrier,
                  :BindCarrier => ufd_settings[ "BindCarrier" ]
              })
              mode 0644
              owner "systemd-network"
              group "systemd-network"
              action :create
              notifies :restart, "service[systemd-networkd]", :delayed
            end

            ### Create symlinks ###
            link "#{outdir}/ufd_#{ufd_carrier}.network" do
              to "#{outdir}/ufd/ufd_#{ufd_carrier}.network"
            end
        end
      end
    end
  end
end
