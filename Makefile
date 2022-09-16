PROJ_DIR := ${CURDIR}

default: build_documentation extract_docc_archive generate_documentation_site_xcode

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

generate_documentation_site_xcode:
	$$(xcrun --find docc) process-archive 																	\
		transform-for-static-hosting "Documentation/Jetworking.doccarchive" 	\
		--output-path "docs" 																									\
		--hosting-base-path "Jetworking"

