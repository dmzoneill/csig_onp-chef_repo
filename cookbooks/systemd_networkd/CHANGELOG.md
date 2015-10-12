systemd_networkd CHANGELOG
==========================

0.2.9
-----
 - Added support for Learning attribute modification on lag device

0.2.8
-----
 - Added support for Link section within LAG interface configuration
 - Removed port number retriction
 - Clean up inconsistent entries in sysfs/networkd/chef            
   Cross checked systemd-network against chef and updated accordingly
 - Added VLAN section for sw0p0
 - Fixed RateLimit missing check in if statement
 - Fix for incrroect key CpuRateLimt shoud be RateLimit
 - Add rxprioritymap back to cpu qos attrs
 - fixes for rate limiting on all ports
 - Added support for pvid attribute.


0.2.7
-----
- Added the ohai plugin - This should be copied using the ohai cookbook
- Fixed bug in folder creation

0.2.6
-----
- Readme cleanup

0.2.5
-----
- More Food critic fixes

0.2.4
-----
- More Food critic fixes
- Changes in GIT repository location on github

0.2.3
-----
- Readme and Food critics

0.2.2
-----
- Numerous food critic fixes

0.2.1
-----
- Added backup support
- fixed deprecations chef 11 - chef 12

0.2.0
-----
- Cookbook redesign
- One cookbook for systemd_networkd configuration

0.1.3 (2015-04-01)
----------------------
- Added uplink failure detection (UFD) support
- Added support for QOS attributes 
- Added supuport configuration options

0.1.2 (2015-03-01)
----------------------
- Added Team support
- Added vlan support for switchports

0.1.1 (2015-02-01)
----------------------
- Added frame forwarding database (FDB / static mac table) support
- Added switchport support and port attributes

0.1.0 (2015-01-01)
----------------------
- Initial release of systemd_networkd

