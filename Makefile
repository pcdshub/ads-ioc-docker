ADS_IOC_VERSION=R0.2.4
#$(shell git describe --tags)

all: image

image:
	docker build -t pcdshub/ads-ioc:$(ADS_IOC_VERSION) .

push:
	docker push pcdshub/ads-ioc:$(ADS_IOC_VERSION)

iocsh:
	docker run -it pcdshub/ads-ioc:$(ADS_IOC_VERSION)

latest:
	docker build -t pcdshub/ads-ioc:latest .
	docker push pcdshub/ads-ioc:latest


.PHONY: all image push iocsh latest
