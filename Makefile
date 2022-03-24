PKG = nlan-pkg.tar.gz

all:	nlan-pkg.tar.gz
	docker buildx build --push --platform linux/amd64,linux/arm/v7,linux/arm64 \
		-t jensenq/nlan-docker . 2>&1 | tee LOG

$(PKG):	nlan/
	tar cvfz $@ nlan

clean:
	rm -f $(PKG)
