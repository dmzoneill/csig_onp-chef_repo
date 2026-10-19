#
# Author:: David O Neill (<david.m.oneill@intel.com>)
# Copyright:: Copyright (c) 2010 Intel Corp.
# License:: Apache License, Version 2.0
#
# The switch plugin implementation lives in the systemd_networkd cookbook.
# ohai::default installs that file over this placeholder when the cookbook
# is on the node. Keeping a plugin file here preserves the ohai plugin path.

canonical = ::File.expand_path(
  '../../../../systemd_networkd/files/default/intel_switch.rb',
  __FILE__
)
if ::File.exist?(canonical)
  load canonical
else
  Ohai.plugin(:IntelSwitch) do
    provides 'intel_switch'
  end
end
