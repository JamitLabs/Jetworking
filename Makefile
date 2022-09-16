PROJ_DIR := ${CURDIR}

default: build_documentation extract_docc_archive

# Build project documentation
build_docc_documentation:
	xcodebuild docbuild 																	\
		-scheme Jetworking																	\
		-destination generic/platform=iOS										\
		-derivedDataPath "Documentation/DocC_Documentation"

extract_docc_archive:
	find "Documentation/DocC_Documentation"	\
		-name "*.doccarchive"									\
		-exec cp -R "{}" "Documentation"			\;

