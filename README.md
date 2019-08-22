ads-ioc docker image
====================

Running an IOC:

```sh
# 
$ eval $(docker-machine env)
$ docker run -im pcdshub/ads-ioc:v0.0.1
epics>
```

Args to be passed to the `adsIoc` binary can be specified after the image name
above. For example:

```sh
$ docker run -im pcdshub/ads-ioc:v0.0.1 st.cmd
```
