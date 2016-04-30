Setup of automatic VM installastions on KVM.
===
1. Install ubuntu and kvm to a machine (Detail guide will follow)
2. Download image of ubuntu to the kvm-server
3. Install ubuntu and LCS on a VM, this will be the main LCS server and will help bootstraping the rest. (Detail guide will follow)
<h3>The problems </h3>
We do not have DHCP or DNS before the LCS is setup, This meens we need to create 2 VMs manual, I think ubuntu-vm-builder is to the rescue.
