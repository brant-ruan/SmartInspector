# Make our first call

## Our clearwater deployment
Our openstack external network is 192.168.32.0/24, we use cloudify to deploy clearwater. Some VM has been associated with a floating ip (eg. ellis) 192.168.32.x which could be visited through VPN from our local laptop, ip address assigned by VPN is 10.x.x.x. VPN is a NAT device, We have tried several types of ISP clients (X-Lite, Jitsi and Blink) on our local laptop but none of them worked. Two Blink clients could establish initial connection successfully but failed with "no ack arrived" after a few seconds(about 15s), since we don't know any details about ISP protocal and the VPN we used, that means we are not sure if NAT tranverse method of our ISP client worked successfuly for the VPN we used. We do all of our following tests on windows VMs which are on the 172.16.10.x/24 network, so the connection between those two ISP clients won't get involved with NAT.

## Clearwater live test
We run the clearwater live test in cloudify CLI VM via docker, all necessary tests passed from live test results, but we are not sure does that mean all function of our clearwater deployment are worked properly, it seems that live test just do some registering and dialing test instead of talking on the soft phone, voice on the soft phone should not be interrupted if everything works, which doesn't involved in live test.

## Soft phone call test
We have three windows VMs and get X-Lite installed
- 172.16.10.8
- 172.16.10.11
- 172.16.10.22

Both 10.8 and 10.22 failed to register to clearwater via tcp, but udp worked. but 10.11 could register successful to clearwater via tcp.

[X-Lite udp] 192.168.10.8 -------✓-------> [X-Lite tcp] 192.168.10.22

Other combinations

[X-Lite udp/tcp] 192.168.10.8 -------×-------> [X-Lite udp] 192.168.10.22