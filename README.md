# nlan-docker
containerized NLAN - Non Local Area Network

# How to use

In the examples that follow, the NLAN configuration is generated and stored in the subdirectory nlan/

## Create the NLAN hub

```mkdir nlan
docker run -it -v nlan:/etc/openvpn/nlan --network host jensenq/nlan-docker /nlan init-hub <hub-public-ip>```

Copy the client tarball to each of the participating client node systems

```scp nlan/nlan-client.tar.gz <target-ip>:```

Start up the hub.  Once you have it working, add ```--restart always```

```docker run -it -v nlan:/etc/openvpn/nlan --network host jensenq/nlan-docker /nlan hub```

## Set up each NLAN client

Extract the client configuration

```mkdir nlan
tar xvf nlan-client.tar.gz```

## Run the NLAN client

<my-ip> is the IP address you want this client to use, e.g. 10.10.1.1

Once you have it working, add ```--restart always```

```docker run -it -v nlan:/etc/openvpn/nlan --network host jensenq/nlan-docker /nlan client <my-ip>```
