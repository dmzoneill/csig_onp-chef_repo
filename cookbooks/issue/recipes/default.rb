#
# Cookbook Name:: issue
# Recipe:: default
#
# Copyright 2014, Intel
#
# All rights reserved - Do Not Redistribute
#

template "/etc/issue" do
  source "issue.erb"
  mode 0644
  owner "root"
  group "root"
  action :create
end
