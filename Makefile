CHART_NAME_1 ?= cray-vpa
CHART_NAME_2 ?= cray-vpa-2
CHART_PATH ?= kubernetes
CHART_VERSION_1 ?= local
CHART_VERSION_2 ?= local

HELM_UNITTEST_IMAGE ?= quintush/helm-unittest:3.3.0-0.2.5


all : charts
charts: chart_setup chart_packages chart_tests
chart_packages: chart_package_1 chart_package_2
chart_tests: chart_test_1 chart_test_2

chart_setup:
		mkdir -p ${CHART_PATH}/.packaged

chart_package_1:
		helm dep up ${CHART_PATH}/${CHART_NAME_1}
		helm package ${CHART_PATH}/${CHART_NAME_1} -d ${CHART_PATH}/.packaged --version ${CHART_VERSION_1}

chart_test_1:
		helm lint "${CHART_PATH}/${CHART_NAME_1}"
		docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME_1}

chart_package_2:
		helm dep up ${CHART_PATH}/${CHART_NAME_2}
		helm package ${CHART_PATH}/${CHART_NAME_2} -d ${CHART_PATH}/.packaged --version ${CHART_VERSION_2}

chart_test_2:
		helm lint "${CHART_PATH}/${CHART_NAME_2}"
		docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME_2}
