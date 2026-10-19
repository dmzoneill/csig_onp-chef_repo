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
  ensure_networkd_dir(dir)
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
  ports_enabled.push( port ) if networkd_enabled?( "Ports" , port )
  ufds_enabled.push( port ) if networkd_enabled?( "UFD" , port )
end

cfg = systemd_networkd
if cfg && cfg.include?( "Teams" )
  cfg[ "Teams" ].each do |team, _teamopts|
    teams_enabled.push( team ) if networkd_enabled?( "Teams" , team )
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


