# Documentation

This folder organizes everything needed to generate the [documentation of `Jetworking`](https://jamitlabs.github.io/Jetworking/):

- `Guides`: Markdown files to be included in the generated documentation.
- `Jazzy Configurations`: Used to configure the documentation generation engine.

The actual generated documentation files are stored in the top-level `docs` folder.

## Regenerating documentation

Whenever, the documentation of a `public`or `open` interface is adjusted, the documentation shall be updated. This can be done by running `make generate-docs` from the root directory of the repository (not: from this directory).

To generate the docs, [Jazzy](https://github.com/realm/jazzy) is required, which can be installed as follows:

```
sudo gem install jazzy
```

## Adding documentation for a new sub module

When a new sub module is added, is is also required to update the documentation generation mechanism:

1. Create the `Guides/SubGuides/NewModuleName` folder with a file `Simple Sample Usage.md` in it (analogously to the way it is done for the `DataTransfer` sub module).
2. In the `Guides/MainGuide.md` file, add the new sub module to the list of available references.
3. Create a new jazzy configuration `NewModuleName.yaml` in the `Jazzy Configurations` folder. It may sensible to just copy and adjust `DataTransfer.yaml` for this.
4. In the Makefile, add a line to also generate documentation for the new sub module when `make generate-docs` is run.
5. Finally run `make generate-docs`.
