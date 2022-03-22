PKG = nlan-pkg.tar.gz

all:	nlan-pkg.tar.gz
	docker build -t jensenq/nlan-docker . 2>&1 | tee LOG

$(PKG):
	tar cvfz $@ nlan

clean:
	rm -f $(PKG)
