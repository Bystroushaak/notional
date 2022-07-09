# Makefile for notional

BASEDIR ?= $(PWD)
APPNAME ?= notional
SRCDIR ?= $(BASEDIR)/src/$(APPNAME)
DISTDIR ?= $(BASEDIR)/dist
DOCSDIR ?= $(BASEDIR)/docs

WITH_VENV = poetry run

SOURCES = "$(SRCDIR)" "$(BASEDIR)/examples" "$(BASEDIR)/tests" "$(BASEDIR)/setup.py"

################################################################################
.PHONY: all

all: build test

################################################################################
.PHONY: build

build: preflight test
	poetry build

################################################################################
.PHONY: docs

docs:
	$(WITH_VENV) mkdocs build

################################################################################
.PHONY: publish

publish: build
	poetry publish --repository pypi

################################################################################
.PHONY: preflight

preflight: test
	$(WITH_VENV) pre-commit run --all-files --verbose

################################################################################
.PHONY: test

test:
	$(WITH_VENV) coverage run "--source=$(SRCDIR)" -m \
		pytest --verbose "$(BASEDIR)/tests"
	$(WITH_VENV) coverage report

################################################################################
.PHONY: coverage

coverage: test
	$(WITH_VENV) coverage html

################################################################################
.PHONY: scrub-vcr

scrub-vcr:
	rm -Rf "$(BASEDIR)/tests/cassettes"

################################################################################
.PHONY: stats

stats:
	cloc $(SOURCES)

################################################################################
.PHONY: venv

venv:
	poetry install --no-root
	$(WITH_VENV) pre-commit install

################################################################################
.PHONY: clean

clean:
	rm -f "$(SRCDIR)/*.pyc"
	rm -f "$(SRCDIR)/examples/*.pyc"
	rm -Rf "$(SRCDIR)/__pycache__"
	rm -Rf "$(BASEDIR)/tests/__pycache__"
	rm -Rf "$(BASEDIR)/.coverage"
	rm -Rf "$(BASEDIR)/.pytest_cache"
	rm -Rf "$(BASEDIR)/build"
	rm -Rf "$(BASEDIR)/notional.egg-info"

################################################################################
.PHONY: clobber

# TODO remove poetry env

clobber: clean scrub-vcr
	$(WITH_VENV) pre-commit uninstall
	rm -Rf "$(DISTDIR)"
	rm -Rf "$(BASEDIR)/site"
	rm -Rf "$(BASEDIR)/htmlcov"
