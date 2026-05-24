install:
	./install.sh

test:
	docker build -t getcred-testenv -f testenv/Dockerfile .
	docker run --rm -ti getcred-testenv

