# frozen_string_literal: true

# Shared lookups for systemd-networkd recipes. Included into Chef::Recipe
# the same way DelConfigFiles is.
module SystemdNetworkdLayout
  def systemd_networkd
    return nil unless node.include?('SystemdNetworkd')

    node['SystemdNetworkd']
  end

  def networkd_record(section, key)
    cfg = systemd_networkd
    return nil unless cfg&.include?(section) && cfg[section].include?(key)

    cfg[section][key]
  end

  # Enabled is exactly true. Does not treat a backup run as enabled.
  def networkd_enabled?(section, key)
    record = networkd_record(section, key)
    return false unless record&.include?('Enabled')

    record['Enabled'] == true
  end

  def port_settings(port)
    networkd_record('Ports', port)
  end

  # True when the port is enabled, or this converge is a backup run.
  def port_or_backup?(port)
    settings = port_settings(port)
    return false unless settings&.include?('Enabled')

    settings['Enabled'] == true || systemd_networkd['Backup'] == true
  end

  def ensure_networkd_dir(path)
    directory path do
      owner 'systemd-network'
      group 'systemd-network'
      mode '0755'
      action :create
    end
  end

  def ensure_networkd_subdir(name)
    ensure_networkd_dir("#{node['SystemdNetworkd']['outdir']}/#{name}")
  end
end

Chef::Recipe.include SystemdNetworkdLayout
