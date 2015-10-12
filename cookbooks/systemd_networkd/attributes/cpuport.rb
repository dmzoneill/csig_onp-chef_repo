if node.attribute?( "ONPPlatform" )
  if node[ "ONPPlatform" ] == "fm10ks"

	default[ "SystemdNetworkdSwitchport" ][ "L2HashKeySupported" ] = \
	        %w( SmacMask DmacMask EthertypeMask VlanId1Mask VlanPri1Mask \
		SymmetrizeMac UseL3Hash UseL2IfIp )

	default[ "SystemdNetworkdSwitchport" ][ "L3HashConfigSupported" ] = \
        	%w( SipMask DipMask L4SrcMask L4DstMask DscpMask IslUserMask \
        	ProtocolMask FlowMask SymmetrizeL3Fields EcmpRotation Protocol1 \
		Protocol2 UseTcp UseUdp UseProtocol1 UseProtocol2 )

	default[ "SystemdNetworkdSwitchport" ][ "CpuSupportedAttributes" ] = \
		%w( LagMode BcastFlooding DefCfi DefDscp DefPri DefPri2 DefSwpri \
                    DefVlan2 FabricLoopback Learning MacTableAddressAgingTime \
                    ParseMpls Parser ParserStoreMpls ParserVlan1Tag \
                    ParserVlan2Tag PauseMode ReplaceDscp RoutedFrameUpdateFields \
                    RxClassPause SecurityAction SwpriDscpPref \
                    SwpriSource UpdateDscp UpdateTtl )

	default[ "SystemdNetworkdSwitchport" ][ "CpuQosSupportedAttributes" ] = \
		%w( AutoPauseMode DscpSwpriMap PcRxmpMap \
                    SwpriTcMap TcPcMap TxPriorityMap RxPriorityMap VpriSwpriMap \
                    ShapingGroupMaxRate ShapingGroupMaxBurst ShapingGroupMinRate \
                    SchedGroupStrict SchedGroupWeight )

	default[ "SystemdNetworkdSwitchport" ][ "RateLimitSupported" ] = \
		%w( BcastRate BcastCapacity McastRate McastCapacity CpuMacRate \
		CpuMacCapacity IgmpRate IgmpCapacity IcmpRate IcmpCapacity \
		ReservedMacRate ReservedMacCapacity MtuViolRate MtuViolCapacity )

  else

	default[ "SystemdNetworkdSwitchport" ][ "L2HashKeySupported" ] = []
	default[ "SystemdNetworkdSwitchport" ][ "L3HashConfigSupported" ] = []
	default[ "SystemdNetworkdSwitchport" ][ "CpuSupportedAttributes" ] = []
	default[ "SystemdNetworkdSwitchport" ][ "CpuQosSupportedAttributes" ] = []
	default[ "SystemdNetworkdSwitchport" ][ "RateLimitSupported" ] = []

  end
end
