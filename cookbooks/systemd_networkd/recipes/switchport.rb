#
# Cookbook Name:: systemd_networkd
# Recipe:: switchport
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/switchport directory if necessary ###
directory "#{outdir}/switchport" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

# create .swport files for each enabled port
node[ "SystemdNetworkd" ][ "PortId" ].each do |port|
  swport_enabled = false

  if node.include?( "SystemdNetworkd" )  
    if node[ "SystemdNetworkd" ].include?( "Ports" )    
      if node[ "SystemdNetworkd" ][ "Ports" ].include?( port )    
        if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "Enabled" )
          if node[ "SystemdNetworkd" ][ "Ports" ][ port ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true
            if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "Attributes" ) || node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "QOS" ) || node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "RateLimit" )
              swport_enabled = true 

              template "#{outdir}/switchport/#{port}.swport" do
                source "switchport/switchport.erb"
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
              link "#{outdir}/#{port}.swport" do
                to "#{outdir}/switchport/#{port}.swport"
              end
            end
          end
        end
      end
    end
  end
end


