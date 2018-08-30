# Bookinfo sample custmized for Kubernetes performance benchmarking

## Build docker images without pushing
```
src/build-services.sh <version>
```

The bookinfo versions are different from Istio versions since the sample should work with any version of Istio.

## Push docker images to docker hub
One script to build the docker images, push them to docker hub and to update the yaml files
```
build_push_update_images.sh <version>
```
