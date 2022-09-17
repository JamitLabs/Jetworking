# Documentation

This folder organizes everything needed to generate the [documentation of `Jetworking`](https://jamitlabs.github.io/Jetworking/):

- `Guides`: markdown files to be included in the generated documentation.
- `Jazzy Configurations`: configuration files of the documentation generation engine.

The generated documentation files are stored in the top-level `docs` folder.

## Regenerating documentation

Whenever the specification of a `public` or `open` interface changes, the documentation can be easily updated by running `make generate-docs` from the [root directory](../).

For the docs generation, [Jazzy](https://github.com/realm/jazzy) is used, which can be installed using RubyGems as follows:

```
sudo gem install jazzy
```

Note for users with **Apple Silicon Macs**: If the `make generate-docs` fails with an error like [this one](https://github.com/realm/jazzy/issues/1259), you may want to try [this solution](https://github.com/ffi/ffi/issues/864#issuecomment-875242776).

## Adding documentation for a new submodule

When a new submodule is added, the documentation generation configuration should also be updated:

1. Create the `Guides/SubGuides/NewModuleName` folder with a file `Simple Sample Usage.md` in it (analogously how it is done in the `DataTransfer` submodule).
2. In the `Guides/MainGuide.md` file, add the new submodule to the list of available references.
3. Create a new jazzy configuration `NewModuleName.yaml` in the `Jazzy Configurations` folder (you could just copy `DataTransfer.yaml` and edit accordingly).
4. In the Makefile, check all scripts and, where needed, add a line to also generate documentation for the new sub module (analogously to the `DataTransfer`submodule).
5. Finally run `make generate-docs`.
