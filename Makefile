ADS_IOC_VERSION=$(shell git describe --tags)

all: image

image:
	docker build -t ads-ioc:$(ADS_IOC_VERSION) .


.PHONY: all image
