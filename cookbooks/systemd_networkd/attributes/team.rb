if node.attribute?( "ONPPlatform" )
  if node[ "ONPPlatform" ] == "fm10ks"

	default[ "SystemdNetworkdSwitchport" ][ "TeamSupportedAttributes" ] = \
		%w( BcastFlooding BcastPruning DefCfi DefDscp DefPri DefPri2 \
		DefSwpri DefVlan2 Dot1xState DropBv DropTagged \
		Loopback MacTableAddressAgingTime MaxFrameSize \
		McastFlooding Learning McastPruning ParseMpls Parser ParserStoreMpls \
		ParserVlan1Tag ParserVlan2Tag PauseMode ReplaceDscp \
		RoutedFrameUpdateFields RxClassPause RxPriorityMap \
		SecurityAction SwpriDscpPref SwpriSource TimestampGeneration \
		UcastFlooding UcastPruning UpdateDscp UpdateTtl )

  else
	default[ "SystemdNetworkdSwitchport" ][ "TeamSupportedAttributes" ] = []
  end
end
