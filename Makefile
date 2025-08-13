.PHONY: install start all

all: install start

install:
	cd codemirrorjs && npm install

start:
	cd codemirrorjs && npm run start