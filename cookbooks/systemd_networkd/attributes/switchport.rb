if node.attribute?( "ONPPlatform" )
  if node[ "ONPPlatform" ] == "fm10ks"

	default[ "SystemdNetworkd" ][ "PortId" ] = [*1..100].map {|s| "sw0p#{s}" }

	default[ "SystemdNetworkdSwitchport" ][ "SupportedAttributes" ] = \
		%w( DefCfi DefDscp DefPri DefSwpri DropBv DropTagged EeeMode \
                    EeeTxActivityTimeout EeeTxLpiTimeout FabricLoopback \
                    IgnoreIfgErrors Learning Loopback ParseMpls Parser \
                    ParserStoreMpls ParserVlan1Tag Tagging TimestampGeneration \
                    UpdateDscp UpdateTtl Autoneg AutonegBasepage AutonegLinkInhbTimer \
                    AutonegLinkInhbTimerKx ReplaceDscp RoutedFrameUpdateFields RxClassPause \
                    RxCutThrough SwpriDscpPref SwpriSource TxClassPause TxCutThrough PauseMode \
                    DefPri2 DefVlan2 Dot1xState ParserVlan2Tag SecurityAction Tagging2 \
                    BcastFlooding UcastFlooding McastFlooding McastPruning BcastPruning \
                    UcastPruning MacTableAddressAgingTime MaxFrameSize LagMode )

        default[ "SystemdNetworkdSwitchport" ][ "QosSupportedAttributes" ] = \
                %w( DscpSwpriMap GlobalUsage SwpriTcMap TcSmpMap \
                    TrapClassSwpriMap VpriSwpriMap TcEnable TcPcMap \
                    PcRxmpMap RxPriorityMap TxPriorityMap \
                    SchedGroupWeight SchedGroupStrict ShapingGroupMaxRate \
                    ShapingGroupMinRate ShapingGroupMaxBurst CirRate \
                    CirAction CirCapacity ColorSource EirAction \
                    EirCapacity EirRate DscpMkdnMap SwpriMkdnMap \
                    MkdnDscp MkdnSwpri DelPolicer SmpLosslessPause )

        default[ "SystemdNetworkdSwitchport" ][ "RateLimitSupported" ] = \
                %w( BcastRate BcastCapacity McastRate McastCapacity CpuMacRate \
                CpuMacCapacity IgmpRate IgmpCapacity IcmpRate IcmpCapacity \
                ReservedMacRate ReservedMacCapacity MtuViolRate MtuViolCapacity )

  else

	default[ "SystemdNetworkd" ][ "PortId" ] = 0
	default[ "SystemdNetworkdSwitchport" ][ "SupportedAttributes" ] = []
        default[ "SystemdNetworkdSwitchport" ][ "QosSupportedAttributes" ] = []

  end
end
