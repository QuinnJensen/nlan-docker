# nlan-docker
NLAN - the Non-Local Area Network - A secure, global, virtual layer-2 overlay network using OpenVPN - containerized

# Overview

NLAN is a simple OpenVPN configuration that connects a user-defined set of trusted hosts anywhere in the world, including roaming machines. Each host gets a layer 2 interface on the NLAN. This interface is a native Linux bridge, named nl0. You chose a private layer 3 network, such as 10.11.12.0/24, to be used on the NLAN. Each participating host uses static layer 3 IP address on that private subnet, applied to their nl0 local interface. Then all layer 2 and layer 3 (TCP/IP) protocols work as if all the machines were connected by a LAN, albeit with latencies and bandwidths limited by the underlying Internet paths. It would also be possible to run a DHCP server on the NLAN to assign addresses.

OpenVPN is used as the secure transport connecting each participating machine to the NLAN hub machine. The NLAN hub is an OpenVPN server with a public Internet address. The NLAN hub creates a layer 2 virtual switch with ports connected to each participating hosts' nl0 interface. Each participating machine itself answers ARP requests from all peers, and the virtual layer 2 infrastructure maintains the MAC address tables dynamically, just as layer 2 bridges do all the time.

OpenVPN is used in UDP datagram mode, thus avoiding any TCP over TCP pathology (TCP really needs packets to be dropped to adjust to congestion, not delayed a long time -- see http://bufferbloat.net/).

If a participating NLAN host roams about and connects via a new public internet path, the virtual switch doesn't care, nor do the other participating hosts thanks to ARP refreshes. Thus, MAC addresses synthesized for each hosts' nl0 bridge don't matter.

# How to use

In the examples that follow, the NLAN configuration is generated and stored in the subdirectory /nlan

## Create the NLAN hub

```
mkdir /nlan
docker run -it -v /nlan:/etc/openvpn/nlan jensenq/nlan-docker /nlan init-hub <hub-public-ip>
```
`<hub-public-ip>` is the IP address or domain name of the hub system

Copy the client tarball to each of the participating client node systems:

```
scp /nlan/nlan-client.tar.gz <target-ip>:
```

Start up the hub.  Once you have it working, add `--restart always`

```
docker run -it -v /nlan:/etc/openvpn/nlan -v /dev/net:/dev/net --cap-add NET_ADMIN --network host jensenq/nlan-docker /nlan hub
```
We use host networking, bind mount /dev/net, and add CAP_NET_ADMIN in order to create, configure and use the tap interface.

## Set up each NLAN client

Extract the client configuration:

```
mkdir /nlan
cd /
tar xvf nlan-client.tar.gz
```

## Run the NLAN client

Once you have it working, add `--restart always`

```
docker run -it -v /nlan:/etc/openvpn/nlan -v /dev/net:/dev/net --cap-add NET_ADMIN --network host jensenq/nlan-docker /nlan client <my-ip>
```
`<my-ip>` is the IP address you want this client to use, e.g. 10.10.1.1

We use host networking to make the host itself accessible from other NLAN client nodes.  Otherwise, the node would only see the inside of the container.
As with the hub instance, we bind mount /dev/net, and add CAP_NET_ADMIN in order to create, configure and use the tap interface.
