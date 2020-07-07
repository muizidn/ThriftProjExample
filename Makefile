gen_thrift:
	thrift -r --gen go:package_prefix=github.com/muizidn/ThriftProjExample/gen-go/ tutorial.thrift

build:
	go build -o ThriftProjExample main.go server.go handler.go client.go

run_server:
	./ThriftProjExample -server

run_client:
	./ThriftProjExample
