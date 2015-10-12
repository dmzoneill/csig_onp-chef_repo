#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright 2014, Intel
#
# All rights reserved - Do Not Redistribute
#

template "/etc/motd" do
  source "motd.erb"
  mode 0644
  owner "root"
  group "root"
  action :create
end
