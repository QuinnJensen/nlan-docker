PKG = nlan-pkg.tar.gz
PLATS = linux/amd64,linux/arm/v7,linux/arm64
REPO = jensenq/nlan-docker

all:	builds
	@ echo
	@ echo run '"make pushes"' to push repos to dockerhub

builds:	build oldbuild

pushes:	pushyoung pushold
	./docker-tags $(REPO)

build:	$(PKG)
	/bin/docker buildx build $(ARGS) --platform $(PLATS) --build-arg=distro=stable -t $(REPO) .

oldbuild:	$(PKG)
	/bin/docker buildx build $(ARGS) --platform $(PLATS) --build-arg=distro=oldoldstable -t $(REPO):2.4.7 .

pushyoung:	$(PKG)
	/bin/docker buildx build $(ARGS) --push --platform $(PLATS) --build-arg=distro=stable -t $(REPO) .

pushold:	$(PKG)
	/bin/docker buildx build $(ARGS) --push --platform $(PLATS) --build-arg=distro=oldoldstable -t $(REPO):2.4.7 .

$(PKG):	nlan/ _clean
	tar cvfz $@ nlan

clean:	_clean
	rm -f $(PKG) .jrc

_clean:
	rm -f nlan/.jrc
