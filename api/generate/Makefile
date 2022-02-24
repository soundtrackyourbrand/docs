build:
	docker build -t docs-generate .

generate: build
	docker run --name docs-generate docs-generate && \
	docker cp docs-generate:/src/source/index.html.md source/index.html.md