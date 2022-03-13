all: build run

build:
	docker build -t broken-baseimage .

run:
	docker inspect broken-baseimage >/dev/null 2>&1 && docker rm -f broken-baseimage || true
	docker run --name broken-baseimage -d -t broken-baseimage