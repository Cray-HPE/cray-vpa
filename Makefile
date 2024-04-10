CHART_NAME ?= cray-vpa
CHART_PATH ?= kubernetes
CHART_VERSION ?= local

HELM_UNITTEST_IMAGE ?= quintush/helm-unittest:3.3.0-0.2.5


all : charts
charts: chart_setup chart_packages chart_tests
chart_packages: chart_package chart_package_2
chart_tests: chart_test

chart_setup:
		mkdir -p ${CHART_PATH}/.packaged

chart_package:
		helm dep up ${CHART_PATH}/${CHART_NAME}
		helm package ${CHART_PATH}/${CHART_NAME} -d ${CHART_PATH}/.packaged --version ${CHART_VERSION}

chart_test:
		helm lint "${CHART_PATH}/${CHART_NAME}"
		docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME}
