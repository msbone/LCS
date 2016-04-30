Setup of automatic VM installastions on KVM. <br />
1. Install ubuntu and kvm to a machine (Detail guide will follow) <br />
2. Download image of ubuntu to the kvm-server <br />
3. Install ubuntu and LCS on a VM, this will be the main LCS server and will help bootstraping the rest. (Detail guide will follow)<br />
<br />
The problems <br />
1. We do not have DHCP or DNS before the LCS is setup.<br />
2. This meens we need to create 2 VMs manual, I think ubuntu-vm-builder is to the rescue.
