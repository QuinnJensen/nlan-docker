FROM debian:stable-slim

RUN apt-get update -q
RUN ln -s /usr/bin/dpkg-split /usr/sbin/
RUN ln -s /usr/bin/dpkg-deb /usr/sbin/
RUN ln -s /bin/rm /usr/sbin/
RUN ln -s /bin/tar /usr/sbin/
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl openvpn easy-rsa openssl \
	perl make libjson-perl \
	bridge-utils iproute2 bsdutils less

COPY nlan-pkg.tar.gz /etc/openvpn
COPY nlan.sh /nlan
