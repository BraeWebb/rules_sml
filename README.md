# rules_sml

Bazel rules for Standard ML using the mlton compiler.

## Usage

WORKSPACE file setup:
```bazel
git_repository(
    name = "rules_sml",
    remote = "https://github.com/BraeWebb/rules_sml.git",
    commit = "<latest_commit_hash>",
)

load("@rules_sml//sml:sml.bzl", "sml_compiler")

sml_compiler(
    name = "ml_compiler",
    release = "Release20200722",
)
```

BUILD rules:
```bazel
load("@rules_sml//sml:sml.bzl", "ml_binary")

ml_binary(
    name = "regex",
    main = "regex.sml"
)
```