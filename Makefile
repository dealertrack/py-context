.PHONY: watch clean-pyc clean-build docs clean

NOSE_FLAGS=-sv --with-doctest --rednose
COVER_CONFIG_FLAGS=--with-coverage --cover-package=pycontext,tests --cover-tests --cover-erase
COVER_REPORT_FLAGS=--cover-html --cover-html-dir=htmlcov
COVER_FLAGS=${COVER_CONFIG_FLAGS} ${COVER_REPORT_FLAGS}

# automatic help generator
help:
	@for f in $(MAKEFILE_LIST) ; do \
		echo "$$f:" ; \
		grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $$f | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' ; \
	done ; \

install:  ## install all requirements including for testing
	pip install -U -r requirements-dev.txt

clean: clean-build clean-pyc clean-test-all  ## remove all artifacts

clean-build:  ## remove build artifacts
	@rm -rf build/
	@rm -rf dist/
	@rm -rf *.egg-info

clean-pyc:  ## remove Python file artifacts
	-@find . -name '*.pyc' -follow -print0 | xargs -0 rm -f
	-@find . -name '*.pyo' -follow -print0 | xargs -0 rm -f
	-@find . -name '__pycache__' -type d -follow -print0 | xargs -0 rm -rf

clean-test:  ## remove test and coverage artifacts
	rm -rf .coverage coverage*
	rm -rf htmlcov/

clean-test-all: clean-test
	rm -rf .tox/

lint:  ## check style with flake8
	flake8 pycontext tests
	importanize --ci

test:  ## run tests quickly with the default Python
	nosetests ${NOSE_FLAGS} tests/ pycontext/

test-coverage:  ## run tests with coverage report
	nosetests ${NOSE_FLAGS} ${COVER_FLAGS} tests/ pycontext/

test-all:  ## run tests on every Python version with tox
	tox

check: lint clean-build clean-pyc clean-test test-coverage  ## run all necessary steps to check validity of project

release: clean  ## release - package and upload a release
	python setup.py sdist upload
	python setup.py bdist_wheel upload

dist: clean  ## package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

.NOTPARALLEL: watch
WATCH_EVENTS=modify,close_write,moved_to,create
watch:  ## watch file changes to run a command, e.g. make watch test
	@if ! type "inotifywait" > /dev/null; then \
		echo "Please install inotify-tools" ; \
	fi; \
	echo "Watching $(pwd) to run: $(WATCH_ARGS)" ; \
	while true; do \
		$(MAKE) $(WATCH_ARGS) ; \
		inotifywait -e $(WATCH_EVENTS) -r --exclude '.*(git|~)' . ; \
	done \

# This needs to be at the bottom as it'll convert things to do-nothing targets
# If the first argument is "watch"...
ifeq (watch,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "watch"
  WATCH_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(WATCH_ARGS):;@:)
endif
