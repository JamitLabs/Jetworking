default: generate-docs

generate-docs:
	@jazzy --config 'Documentation/Jazzy Configurations/Jetworking.yaml' --output docs; \
	sed -i '' "s|$PWD|Root|g" docs/undocumented.json; \
	jazzy --config 'Documentation/Jazzy Configurations/DataTransfer.yaml' --output docs/Modules/DataTransfer; \
	sed -i '' "s|$PWD|Root|g" docs/Modules/DataTransfer/undocumented.json; \
	echo "✅ Documentation generated and stored to the docs folder";

lint-docsUpToDate:
	@echo "📄 Generating documentation to check whether it matches the content of the docs folder..."; \
	jazzy --config 'Documentation/Jazzy Configurations/Jetworking.yaml' --output .docsNew; \
	sed -i '' "s|$PWD|Root|g" .docsNew/undocumented.json; \
	jazzy --config 'Documentation/Jazzy Configurations/DataTransfer.yaml' --output .docsNew/Modules/DataTransfer; \
	sed -i '' "s|$PWD|Root|g" .docsNew/Modules/DataTransfer/undocumented.json; \
	if ! find docs .docsNew -type f ! -name 'undocumented.json' -print | sed -e 's|.*/||' | diff -X - -r docs .docsNew &>/dev/null; then \
		>&2 echo "⛔️ The content of the docs folder is not up-to-date. This issue can be addressed by regenerating the docs."; \
		rm -rf .docsNew; \
		exit 1; \
	fi; \
	echo "✅ Linting successful: Documentation in the docs folder is up-to-date."; \
	rm -rf .docsNew;

.PHONY: generate-docs
