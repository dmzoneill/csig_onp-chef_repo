#
# Cookbook Name:: systemd_networkd
# Recipe:: default
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

require 'date'
time_string = DateTime.now.strftime( "%Y%m%d%H%M" )
backup = node[ "SystemdNetworkd" ][ "Backup" ]

if backup == true
  outdir = "/etc/systemd/network/backup/#{time_string}"
else
  outdir = "/etc/systemd/network"
end

node.default[ "SystemdNetworkd" ][ "outdir" ] = outdir

createdirs = [ "/etc/systemd/network" , "/etc/systemd/network/backup" ]
createdirs.each do |dir|
  ### Create networkd dirs if they don't exist ###
  directory dir do
    owner 'systemd-network'
    group 'systemd-network'
    mode '0755'
    action :create
  end
end

### create backup dir
directory outdir do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
  only_if { backup == true }
end


### Delete unused systemd directories ###
deletedirs = [ "/usr/lib/systemd/network/" , "/run/systemd/network/" , "/lib/systemd/network/" ]
deletedirs.each do |deldir|
  directory deldir do
    recursive true
    action :delete
  end
end

### Restart service ###
service "systemd-networkd" do
  supports :restart => true, :reload => true
  action :nothing
end

## Execute command ###
execute "udevadm-trigger-net-add" do
  command "udevadm trigger --subsystem-match=net --action=add"
  action :nothing
end


include_recipe "systemd_networkd::backup"
include_recipe "systemd_networkd::link"
include_recipe "systemd_networkd::switchport"
include_recipe "systemd_networkd::cpuport"
include_recipe "systemd_networkd::team"
include_recipe "systemd_networkd::static_mac_table"
include_recipe "systemd_networkd::ufd"

ports_enabled = []
ufds_enabled = []
teams_enabled = []

node[ "SystemdNetworkd" ][ "PortId" ].each do |port|
  if node.include?( "SystemdNetworkd" )
    if node[ "SystemdNetworkd" ].include?( "Ports" )
      if node[ "SystemdNetworkd" ][ "Ports" ].include?( port )
        if node[ "SystemdNetworkd" ][ "Ports" ][ port ].include?( "Enabled" )
          if node[ "SystemdNetworkd" ][ "Ports" ][ port ][ "Enabled" ] == true
            
	    ports_enabled.push( port )

          end
        end
      end
    end

    if node[ "SystemdNetworkd" ].include?( "UFD" )
      if node[ "SystemdNetworkd" ][ "UFD" ].include?( port )
        if node[ "SystemdNetworkd" ][ "UFD" ][ port ].include?( "Enabled" )
          if node[ "SystemdNetworkd" ][ "UFD" ][ port ][ "Enabled" ] == true

            ufds_enabled.push( port )

          end
        end
      end
    end
  end
end

if node.include?( "SystemdNetworkd" )
  if node[ "SystemdNetworkd" ].include?( "Teams" )
    node[ "SystemdNetworkd" ][ "Teams" ].each do |team,teamopts|
      if node[ "SystemdNetworkd" ][ "Teams" ][ team ].include?( "Enabled" )
        if node[ "SystemdNetworkd" ][ "Teams" ][ team ][ "Enabled" ] == true

          teams_enabled.push( team )

        end
      end
    end    
  end
end

ret = del_files( ports_enabled, ufds_enabled, teams_enabled )

ruby_block "conditional-restart" do
  block do
    ### Empty block ###
  end
  notifies :restart, "service[systemd-networkd]", :delayed
  not_if do 
    ret == 0 || ( backup != false && backup != nil ) 
  end 
end


