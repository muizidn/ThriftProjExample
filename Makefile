gen_thrift:
	thrift -r --gen go:package_prefix=github.com/muizidn/goproj/gen-go/ tutorial.thrift

build:
	go build -o goproj main.go server.go handler.go client.go

run_server:
	./goproj -server

run_client:
	./goproj
