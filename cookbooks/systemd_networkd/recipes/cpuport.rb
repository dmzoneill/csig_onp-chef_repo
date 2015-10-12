#
# Cookbook Name:: systemd_networkd
# Recipe:: cpuport
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/cpuport directory if necessary ###
directory "#{outdir}/cpuport" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end


if node.include?( "SystemdNetworkd" )    
  if node[ "SystemdNetworkd" ].include?( "Ports" )   

    if node[ "SystemdNetworkd" ][ "Ports" ].include?( "sw0p0" ) 
      if node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "L2HashKey" ) ||
        node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "L3HashConfig" ) ||
        node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "Attributes" ) ||
        node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "RateLimit" ) ||
        node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "Vlans" ) ||
        node[ "SystemdNetworkd" ][ "Ports" ][ "sw0p0" ].include?( "QOS" )

        template "#{outdir}/cpuport/sw0p0.swport" do
          source "cpuport/cpuport.erb"
          mode 0644
          owner "systemd-network"
          group "systemd-network"
          action :create
          notifies :restart, "service[systemd-networkd]", :delayed
        end
        
        link "#{outdir}/sw0p0.swport" do
          to "#{outdir}/cpuport/sw0p0.swport"
        end

      end
    end
   
  end
end
