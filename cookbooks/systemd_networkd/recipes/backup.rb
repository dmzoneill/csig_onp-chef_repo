#
# Cookbook Name:: systemd_networkd
# Recipe:: backup
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#
require 'json'

createdirs = [ "/opt/chef/embedded/apps/ohai/lib/ohai/plugins/intel" ]
createdirs.each do |dir|
  ### Create networkd dirs if they don't exist ###
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end


cookbook_file "cfgdump.rb" do
  path "/usr/bin/cfgdump"
  mode '0755'
  action :create
end

cookbook_file "intel_switch.rb" do
  path "/opt/chef/embedded/apps/ohai/lib/ohai/plugins/intel/intel_switch.rb"
  action :create
end

backup = node[ "SystemdNetworkd" ][ "Backup" ]

if backup == true
  backup = %x( ohai intel_switch )
  parsed = JSON.parse( backup )
  node.default[ "SystemdNetworkd" ][ "Ports" ] = parsed[ "Ports" ]
  node.default[ "SystemdNetworkd" ][ "Teams" ] = parsed[ "Teams" ]
  node.default[ "SystemdNetworkd" ][ "UFD" ] = parsed[ "UFD" ]
end

