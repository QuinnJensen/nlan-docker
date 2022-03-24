PKG = nlan-pkg.tar.gz

all:	nlan-pkg.tar.gz
	docker buildx build --push --platform linux/amd64,linux/arm/v7,linux/arm64 \
		-t jensenq/nlan-docker . 2>&1 | tee LOG

$(PKG):	nlan/ _clean
	tar cvfz $@ nlan

clean:	_clean
	rm -f $(PKG) .jrc

_clean:
	rm -f nlan/.jrc
