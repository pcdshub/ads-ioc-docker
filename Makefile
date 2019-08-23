ADS_IOC_VERSION=$(shell git describe --tags)

all: image

image:
	docker build -t pcdshub/ads-ioc:$(ADS_IOC_VERSION) .

push:
	docker push pcdshub/ads-ioc:$(ADS_IOC_VERSION)


.PHONY: all image push
