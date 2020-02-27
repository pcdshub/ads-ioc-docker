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

Updating ads-ioc-docker
=======================

Prior to updating ads-deploy, first update this docker image.

    1. Tag and release ads-ioc
       a. Use the R0.0.0 style in accordance with module/IOC
          versioning standards
    2. Update the Dockerfile
        a. Update any dependency versions that may have changed in the
           latest release
        b. If the ADS module itself has been updated, update
            `ADS_MODULE_VERSION`.
        c. Near the end of the Dockerfile, update `ADS_IOC_VERSION`.
           Note that this is separate from the other sections, as putting it
           near the top would cause an unnecessary rebuild of all dependencies
           upon update of the `ADS_IOC_VERSION`.
    3. Rebuild
        ```
        $ export ADS_IOC_VERSION={version here}
        $ docker build -t pcdshub/ads-ioc:${ADS_IOC_VERSION} .
        $ docker build -t pcdshub/ads-ioc:latest .
        ```
    4. Push
        ```
        $ docker push pcdshub/ads-ioc:${ADS_IOC_VERSION}
        $ docker push pcdshub/ads-ioc:latest
        ```
    5. Commit, tag, and push to GitHub
        ```
        $ git tag ${ADS_IOC_VERSION}
        $ git push
        $ git push --tags
        ```

