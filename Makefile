REPO ?= peopleai
PIP_CFG ?= ~/.config/pip/pip.conf
BUMP_LEVEL ?= patch
ARTIFACTORY_REPO ?= https://peopleai.jfrog.io/peopleai/api/pypi/pai-pypi

.PHONY: bumpversion
bumpversion:
	@bumpversion $(BUMP_LEVEL)

.PHONY: clean
clean:
	@python setup.py clean --all

.PHONY: build
build: clean
	@python setup.py sdist bdist_wheel

.PHONY: publish
publish:
	@twine upload -r $(REPO) --config-file $(PIP_CFG) dist/*

.PHONY: publish-circle
publish-circle:
	@twine upload --verbose --repository-url $(ARTIFACTORY_REPO) -u ${ARTIFACTORY_PYPI_USERNAME} -p ${ARTIFACTORY_PYPI_PASSWORD} dist/*

.PHONY: start-test-env
start-test-env:
	docker-compose -f docker-compose.yml up -d

.PHONY: start-integration-test
start-integration-test:
	DOCKER_CLUSTER=1 python setup.py test

.PHONY: stop-test-env
stop-test-env:
	docker-compose -f docker-compose.yml down

.PHONY: publish-circle
publish-circle:
	@aws codeartifact login --tool twine --domain people-ai --repository pai-pypi --region us-east-1 --duration 900
	@twine upload --repository codeartifact dist/*