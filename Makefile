default: help

.PHONY: help
help:   ## show this help
	@echo 'usage: make [target] ...'
	@echo ''
	@echo 'targets:'
	@egrep '^(.+)\:\ .*##\ (.+)' ${MAKEFILE_LIST} | sed 's/:.*##/#/' | column -t -c 2 -s '#'

.PHONY: clean
clean:
	go clean

.PHONY: build
build:
	go build -ldflags -s
	cd pharodctl && go build -ldflags -s

.PHONY: check
check:
	@echo "running golint..."
	@go list ./... | grep -v /vendor/ | xargs -L1 golint
	go vet

.PHONY: dependencies
dependencies:
	go mod tidy
	go mod verify

.PHONY: dependencies-clean
dependencies-clean:
	rm -f go.sum
	rm -rf vendor
	go clean -modcache

.PHONY: links
links:
	ln -sf ${PWD}/pharod-start /usr/local/bin/pharod-start
	ln -sf ${PWD}/pharod-stop /usr/local/bin/pharod-stop
	ln -sf ${PWD}/pharod /usr/local/bin/pharod
	ln -sf ${PWD}/pharodctl/pharodctl /usr/local/bin/pharodctl

.PHONY: test
test:
	go test -p 1 ./... -coverprofile coverage.out
	go tool cover -func coverage.out | grep ^total:
