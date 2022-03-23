FROM debian:stable-slim

RUN apt-get update -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl openvpn easy-rsa openssl \
	perl make libjson-perl \
	bridge-utils iproute2 bsdutils less tcpdump

COPY nlan-pkg.tar.gz /etc/openvpn
COPY nlan.sh /nlan
