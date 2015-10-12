#
# Cookbook Name:: issue
# Recipe:: default
#
# Copyright 2014, Intel
#
# All rights reserved - Do Not Redistribute
#

template "/etc/nsswitch.conf" do
  source "nsswitch.conf.erb"
  mode 0644
  owner "root"
  group "root"
  action :create
end
