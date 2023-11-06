export IMAGE=$(shell basename $$PWD)
export BUILDTAG:=$(shell date +%Y%m%d.%H%M%S)

all: image

clean:

image:
	docker build --build-arg BUILDTAG=$(BUILDTAG) -t $(IMAGE) .
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE):latest

imagerun:
	docker build --progress plain -t $(IMAGE) .
	docker run -it -e DEBUG=y $(IMAGE)


.PHONY: all clean distclean install image imagerun
