# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

#
# Author:: David O Neill (<david.m.oneill@intel.com>)
# Copyright:: Copyright (c) 2010 Intel Corp.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Ohai.plugin(:IntelSwitch) do
  provides 'intel_switch'

  # Yields each netdev that exposes a switch sysfs directory.
  def each_switch_netdev
    listing = shell_out('ls /sys/class/net/')
    listing.stdout.lines do |line|
      name = line.strip
      yield name if File.directory?("/sys/class/net/#{name}/switch")
    end
  end

  # Walks parallel sysfs and attribute-name lists into [name, value] rows.
  def collect_indexed_attrs(port, attrs_sysfs, attrs_sd)
    ret = []
    (0...attrs_sysfs.size).each do |index|
      val = get_attr(port, attrs_sysfs[index])
      if val != ''
        if val.include?('index')
          ret = attr_add_multiple(ret, attrs_sd[index], val)
        else
          attrarr = [attrs_sd[index], val]
          ret.push(attrarr)
        end
      end
    end
    ret
  end

  # Walks parallel sysfs and attribute-name lists into a Mash.
  def map_prefixed_attrs(port, prefix, attrs_sysfs, attrs_sd)
    ret = Mash.new
    (0...attrs_sysfs.size).each do |index|
      val = get_attr(port, prefix + attrs_sysfs[index])
      ret[attrs_sd[index]] = val if val != ''
    end
    ret
  end

  # Gets the configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the port configuration
  def get_attributes(port)
    attrs_sysfs = %w[ def_cfi def_dscp def_pri def_swpri drop_bv drop_tagged
                      eee_mode eee_tx_activity_timeout eee_tx_lpi_timeout
                      fabric_loopback ignore_ifg_errors learning loopback
                      parse_mpls parser parser_store_mpls parser_vlan1_tag tagging
                      timestamp_generation update_dscp update_ttl autoneg
                      autoneg_basepage autoneg_link_inhb_timer autoneg_link_inhb_timer_kx
                      replace_dscp routed_frame_update_fields rx_class_pause
                      rx_cut_through swpri_dscp_pref swpri_source tx_class_pause
                      tx_cut_through pause_mode def_pri2 def_vlan2 dot1x_state
                      parser_vlan2_tag security_action tagging2 bcast_flooding
                      ucast_flooding mcast_flooding mcast_pruning bcast_pruning
                      ucast_pruning mac_table_address_aging_time max_frame_size lag_mode  ]

    attrs_sd = %w[ DefCfi DefDscp DefPri DefSwpri DropBv DropTagged
                   EeeMode EeeTxActivityTimeout EeeTxLpiTimeout
                   FabricLoopback IgnoreIfgErrors Learning Loopback
                   ParseMpls Parser ParserStoreMpls ParserVlan1Tag Tagging
                   TimestampGeneration UpdateDscp UpdateTtl Autoneg
                   AutonegBasepage AutonegLinkInhbTimer AutonegLinkInhbTimerKx
                   ReplaceDscp RoutedFrameUpdateFields RxClassPause
                   RxCutThrough SwpriDscpPref SwpriSource TxClassPause
                   TxCutThrough PauseMode DefPri2 DefVlan2 Dot1xState
                   ParserVlan2Tag SecurityAction Tagging2 BcastFlooding
                   UcastFlooding McastFlooding McastPruning BcastPruning
                   UcastPruning MacTableAddressAgingTime MaxFrameSize LagMode ]

    collect_indexed_attrs(port, attrs_sysfs, attrs_sd)
  end

  # Gets the QOS configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the QOS configuration
  def get_qos(port)
    attrs_sysfs = %w[ auto_pause_mode dscp_swpri_map global_usage priv_wm shared_pri_wm
                      shared_soft_drop_wm shared_soft_drop_wm_hog shared_soft_drop_wm_jitter
                      shared_usage swpri_tc_map tc_smp_map trap_class_swpri_map vpri_swpri_map
                      tc_enable private_pause_on_wm private_pause_off_wm shared_pause_off_wm
                      shared_pause_on_wm shared_pause_enable tc_pc_map pc_rxmp_map l2_vpri1_map
                      rx_priority_map tx_priority_map sched_groups smp_lossless_pause
                      sched_group_weight sched_pri_sets sched_group_strict shaping_group_max_rate
                      shaping_group_min_rate shaping_group_max_burst cir_rate cir_action
                      cir_capacity color_source eir_action eir_capacity eir_rate
                      dscp_mkdn_map swpri_mkdn_map mkdn_dscp mkdn_swpri del_policer ]

    attrs_sd = %w[ AutoPauseMode DscpSwpriMap GlobalUsage PrivWm SharedPriWm
                   SharedSoftDropWm SharedSoftDropWmHog SharedSoftDropWmJitter
                   SharedUsage SwpriTcMap TcSmpMap TrapClassSwpriMap VpriSwpriMap
                   TcEnable PrivatePauseOnWm PrivatePauseOffWm SharedPauseOffWm
                   SharedPauseOnWm SharedPauseEnable TcPcMap PcRxmpMap L2Vpri1Map
                   RxPriorityMap TxPriorityMap SchedGroups SmpLosslessPause
                   SchedGroupWeight SchedPriSets SchedGroupStrict ShapingGroupMaxRate
                   ShapingGroupMinRate ShapingGroupMaxBurst CirRate CirAction
                   CirCapacity ColorSource EirAction EirCapacity EirRate
                   DscpMkdnMap SwpriMkdnMap MkdnDscp MkdnSwpri DelPolicer ]

    collect_indexed_attrs(port, attrs_sysfs, attrs_sd)
  end

  # Gets the rate limiting configuration
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the port configuration
  def get_rate_limit(port)
    attrs_sysfs = %w[ bcast_rate bcast_capacity mcast_rate mcast_capacity cpu_mac_rate cpu_mac_capacity
                      igmp_rate igmp_capacity icmp_rate icmp_capacity reserved_mac_rate reserved_mac_capacity
                      mtu_viol_rate mtu_viol_capacity ]

    attrs_sd = %w[ BcastRate BcastCapacity McastRate McastCapacity CpuMacRate CpuMacCapacity
                   IgmpRate IgmpCapacity IcmpRate IcmpCapacity ReservedMacRate ReservedMacCapacity
                   MtuViolRate MtuViolCapacity ]

    map_prefixed_attrs(port, '', attrs_sysfs, attrs_sd)
  end

  # Gets the L2 hashing configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the L2 configuration
  def get_l2_hash_key(port)
    attrs_sysfs = %w[ smac_mask dmac_mask ethertype_mask vlan_id1_mask vlan_pri1_mask symmetrize_mac
                      use_l3_hash use_l2_if_ip ]

    attrs_sd = %w[ SmacMask DmacMask EthertypeMask VlanId1Mask VlanPri1Mask SymmetrizeMac
                   UseL3Hash UseL2IfIp ]

    map_prefixed_attrs(port, 'l2_hash_key_', attrs_sysfs, attrs_sd)
  end

  # Gets the L3 hashing configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the L3 configuration
  def get_l3_hash_config(port)
    attrs_sysfs = %w[ sip_mask dip_mask l4_src_mask l4_dst_mask dscp_mask isl_user_mask
                      protocol_mask flow_mask symmetrize_l3_fields ecmp_rotation protocol1 protocol2
                      use_tcp use_udp use_protocol1 use_protocol2 ]

    attrs_sd = %w[ SipMask DipMask L4SrcMask L4DstMask DscpMask IslUserMask
                   ProtocolMask FlowMask SymmetrizeL3Fields EcmpRotation Protocol1 Protocol2
                   UseTcp UseUdp UseProtocol1 UseProtocol2 ]

    map_prefixed_attrs(port, 'l3_hash_config_', attrs_sysfs, attrs_sd)
  end

  # Adds one indexed port attribute value
  # Params:
  # +arr+:: the arr to add the values to
  # +key+:: the attribute to query from sysfs
  # +indexvals+:: the index values that are to be split
  # Returns:
  # (Mash) return the entire Mash
  def attr_add_multiple(arr, key, indexvals)
    indexvals = indexvals.strip

    if indexvals.include?("\n")
      lines = indexvals.split("\n")
      (0...lines.size).each do |line|
        parts = lines[line].split(/index/)
        attrarr = [key, "#{parts[1].strip} #{parts[0].strip}"]
        arr.push(attrarr)
      end
    else
      parts = indexvals.split(/index/)
      attrarr = [key, "#{parts[1].strip} #{parts[0].strip}"]
      arr.push(attrarr)
    end

    arr
  end

  # Gets the port attribute value
  # Params:
  # +port+:: the netdev to query
  # +attr+:: the attribute to query from sysfs
  # Returns:
  # (string) the value
  def get_attr(port, attr)
    if File.exist?("/sys/class/net/#{port}/switch/#{attr}")
      begin
        fb = File.open("/sys/class/net/#{port}/switch/#{attr}", 'r')
        contents = fb.read
      rescue SystemCallError
        contents = ''
      end
    else
      contents = ''
    end
    contents.chomp
  end

  # Gets the up/down state of a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (string) "true" / "false"
  def get_state(port)
    line = shell_out("ip link show #{port} | head -n 1").stdout.strip

    if line =~ /state (\w+)/
      return true if Regexp.last_match(1).downcase == 'up'

      return false

    end

    false
  end

  # Inspects Port configuration
  # Params:
  def switch_ports
    ports = Mash.new

    each_switch_netdev do |name|
      if name == 'sw0p0'
        ports[ name ] = {
          Attributes: get_attributes(name),
          QOS: get_qos(name),
          RateLimit: get_rate_limit(name),
          L2HashKey: get_l2_hash_key(name),
          L3HashConfig: get_l3_hash_config(name)
        }
      elsif port?(name) == true
        ports[ name ] = {
          Enabled: get_state(name),
          Attributes: get_attributes(name),
          RateLimit: get_rate_limit(name),
          Vlans: get_vlans(name),
          QOS: get_qos(name),
          FDB: get_fdbs(name)
        }
      end
    end

    ports
  end

  # Checks to see if netdev is a port
  # Params:
  def port?(netdev)
    so = shell_out('ip link')

    so.stdout.lines do |line|
      return false if line =~ /master #{netdev}/
    end

    true
  end

  # Inspects the team configuration
  # Params:
  def switch_teams
    teams = Mash.new

    # get all the masters
    each_switch_netdev do |name|
      portline = shell_out("ip link show #{name} | head -n 1").stdout.strip
      next unless portline =~ /master (\w+)/

      master = Regexp.last_match(1)
      next unless teams.key?(master) == false

      teams[master] = {
        'Enabled' => get_state(master),
        'Members' => get_team_members(master),
        'Attributes' => get_attributes(master),
        'Vlans' => get_vlans(master),
        'FDB' => get_fdbs(master)
      }
    end

    teams
  end

  # Gets the members of a team netdev
  # Params:
  # +master+:: The team netdev to get the member ports
  def get_team_members(master)
    members = []

    # get all the masters
    each_switch_netdev do |name|
      portline = shell_out("ip link show #{name} | head -n 1").stdout.strip
      members.push(Regexp.last_match(1)) if portline =~ /\d+: (\w+):.*?master #{master}/
    end

    members
  end

  # Gets the vlans assigned to a netdev
  # Params:
  # +master+:: The netdev to get the vlans off
  def get_vlans(netdev)
    vlans = Mash.new
    ids = []

    so = shell_out("bridge vlan show dev #{netdev}")

    # port    vlan ids
    # team1    1 PVID Egress Untagged
    #          20 Egress Untagged
    #          25
    #
    # team1    1 PVID Egress Untagged
    #          20 Egress Untagged
    #          25

    i = 1
    hasvlan = false

    so.stdout.lines do |line|
      if line =~ /^port\s+vlan\s+ids$/
        hasvlan = true
      else
        break if hasvlan == false

        tag = "tag#{i}"

        if line =~ /\s(\d+)\s+(Egress Untagged)?/
          tagged = Regexp.last_match(2).nil? ? 'false' : 'true'
          unless ids.include?(Regexp.last_match(1))
            vlans[ tag ] = {
              'Id' => Regexp.last_match(1),
              'EgressUntagged' => tagged
            }
            i += 1
            ids.push(Regexp.last_match(1))
          end
        end

        if line =~ /\s(\d+)\s+i(PVID )(Egress Untagged)?/
          tagged = Regexp.last_match(3).nil? ? 'false' : 'true'
          unless ids.include?(Regexp.last_match(1))
            vlans[ tag ] = {
              'Id' => Regexp.last_match(1),
              'Pvid' => Regexp.last_match(2),
              'EgressUntagged' => tagged
            }
            i += 1
            ids.push(Regexp.last_match(1))
          end
        end

      end
    end

    vlans
  end

  # Inspects FDB configuration
  # Params:
  def get_fdbs(netdev)
    fdbs = []

    so = shell_out("bridge fdb show brport #{netdev}")

    so.stdout.lines do |line|
      # ab:bc:cc:00:01:02 vlan 3 self permanent
      if line.strip =~ /^(([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])) vlan (\d+).*?$/
        line.strip.match(/^(([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])) vlan (\d+).*?$/)
        entry = ['MACAddress', Regexp.last_match(1), 'VLANId', Regexp.last_match(4)]
        fdbs.push(entry)
      end
    end

    fdbs
  end

  # Gets any ports bound to this netdev and returns them as an array
  def get_ufd_port_binds(netdev)
    Ohai::Log.debug("Master: #{netdev}")
    bound = false
    boundports = []
    so = shell_out("networkctl status #{netdev}")

    so.stdout.lines do |line|
      if bound == true
        break unless line.strip.match(/([a-zA-Z0-9]+)/)

        Ohai::Log.debug("Match: #{Regexp.last_match(1)}")
        break unless port?(Regexp.last_match(1)) == true

        Ohai::Log.debug("Add port: #{Regexp.last_match(1)}")
        boundports.push(Regexp.last_match(1))

      elsif line.strip.match(/Carrier Bound To:\s+([a-zA-Z0-9]+)/)
        Ohai::Log.debug("Carrier bound to: #{Regexp.last_match(1)}")
        if port?(Regexp.last_match(1)) == true
          Ohai::Log.debug("Confirmed master: #{Regexp.last_match(1)}")
          boundports.push(Regexp.last_match(1))
          bound = true
        end
      end
    end

    boundports
  end

  # Inspects UFD configuration
  # Params:
  def switch_ufd
    ret = Mash.new

    # get all the masters
    each_switch_netdev do |name|
      boundports = get_ufd_port_binds(name)
      next unless boundports.length.positive?

      ret[ name ] = {
        'Enabled' => true,
        'BindCarrier' => boundports.join(' ')
      }
    end

    ret
  end

  collect_data do
    intel_switch Mash.new
    intel_switch[:Teams] = switch_teams
    intel_switch[:UFD] = switch_ufd
    intel_switch[:Ports] = switch_ports
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
