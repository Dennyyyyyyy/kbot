APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=denysdl
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=arm64

format: 
	gofmt -s -w ./

lint: 
	staticcheck ./

test: 
	go test -v

get: 
	go get

build:
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm64 go build -v -o kbot -ldflags "-X="github.com/Dennyyyyyyy/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean: 
	rm -rf kbot
