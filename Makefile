.PHONY: all build install help

all:
	bundle exec jekyll serve

build:
	bundle exec jekyll build

install:
	gem install bundler jekyll
	bundle install
	curl -o _assets/katex.min.js https://cdn.jsdelivr.net/npm/katex@latest/dist/katex.min.js

help:
	@echo "!! Ensure that you have the correct version of Ruby installed."
	@echo "!! Check https://pages.github.com/versions/ for the required version."
	@echo ""
	@echo "make [all]      Build and serve the site"
	@echo "make build      Build the site only"
	@echo "make install    Install all Gems and download latest KaTeX"
	@echo "make help       Display this dialogue"
