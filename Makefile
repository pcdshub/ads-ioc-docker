all: image

image:
	DOCKER_BUILDKIT=1 docker build --rm=false -t pytmc:v0.0.0 .


.PHONY: all image
