.PHONY: watch clean-pyc clean-build docs clean

install:  ## install all requirements including for testing
	poetry install

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
	rm -rf .pytest_cache
	rm -rf .coverage coverage*
	rm -rf htmlcov/

clean-test-all: clean-test
	rm -rf .tox/

lint:  ## check style with flake8
	poetry run flake8

test:  ## run tests quickly with the default Python
	poetry run pytest

check: lint clean-build clean-pyc clean-test test  ## run all necessary steps to check validity of project

#release: clean  ## release - package and upload a release
#	python setup.py sdist upload
#	python setup.py bdist_wheel upload
#
#dist: clean  ## package
#	python setup.py sdist
#	python setup.py bdist_wheel
#	ls -l dist
