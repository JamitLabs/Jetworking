PROJ_DIR := ${CURDIR}

default: generate-docs

generate-docs:
	jazzy --config 'Documentation/Jazzy Configurations/Jetworking.yaml' && \
	jazzy --config 'Documentation/Jazzy Configurations/DataTransfer.yaml'

.PHONY: generate-docs
