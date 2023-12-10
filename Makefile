APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/dennyyyyyyy
#Docker registry
#REGISRY=denysdl
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64
#TARGETOS=$(shell go env GOOS) 
#TARGETARCH=$(shell go env GOARCH)
#dpkg --print-architecure

format: 
	gofmt -s -w ./

lint: 
	staticcheck ./

test:
	go test -v

get: 
	go get

linux: 
	make build TARGETOS=linux TARGETARCH=amd64

arm64:
	make build  TARGETOS=darwin TARGETARCH=arm64

macos:
	make build TARGETOS=darwin TARGETARCH=amd64

windows:
	make build TARGETOS=windows TARGETARCH=amd64

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/Dennyyyyyyy/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean: 
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}