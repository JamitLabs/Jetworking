PROJ_DIR := ${CURDIR}

default: build_documentation
# Build project documentation
build_docc_documentation:
	xcodebuild docbuild 																	\
		-scheme Jetworking																	\
		-destination generic/platform=iOS										\
		-derivedDataPath "Documentation/DocC_Documentation"

