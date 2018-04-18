# If we have `--squash` support, then use it!
ifneq ($(shell docker build --help 2>/dev/null | grep squash),)
DOCKER_BUILD = docker build --squash
else
DOCKER_BUILD = docker build
endif

all: build

build: Makefile Dockerfile
	$(DOCKER_BUILD) -t thinkmassive/nginx-certbot .
	@echo "Done!  Use docker run thinkmassive/nginx-certbot to run"

push:
	docker push thinkmassive/nginx-certbot
