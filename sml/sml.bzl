_ml_compilers = {
    "Release20200722": {
        "linux": {
            "sha": "2829b0d138a6664022c14b0814aae82f68fba3f8443dd454737697ad6cce4b92",
            "url": "https://sourceforge.net/projects/mlton/files/mlton/20200722/mlton-20200722-1.amd64-linux.tgz",
            "prefix": "mlton-20200722-1.amd64-linux",
        }
    }
}

def _sml_compiler_repository(ctx):
    release = ctx.attr.release
    if release not in _ml_compilers:
        fail("Unknown release version: " + release)

    platform = ctx.os.name
    if platform not in _ml_compilers[release]:
        fail("Unsupported operating system: " + platform)
    
    remote = _ml_compilers[release][platform]

    ctx.download_and_extract(
        url = [remote["url"]],
        sha256 = remote["sha"],
        stripPrefix = remote["prefix"],
    )

    ctx.file("BUILD", """
filegroup(
    name = "library",
    srcs = glob(["lib/**/*"]),
    visibility = ["//visibility:public"],
)
exports_files(glob(["**/*"]))
""")
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))

sml_compiler = repository_rule(
    attrs = {
        "release": attr.string(mandatory = True),
    },
    implementation = _sml_compiler_repository,
)


def _ml_binary(ctx):
    binary = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.run(
        executable = ctx.executable._compiler,
        use_default_shell_env = True,
        arguments = [
            "-output",
            binary.path,
            ctx.file.main.path,            
        ],
        inputs = depset(
            direct = ctx.files.main + ctx.files.srcs + ctx.files._compiler_library,
        ),
        outputs = [binary],
        tools = [ctx.executable._compiler],
    )

    return [DefaultInfo(executable = binary)]


ml_binary = rule(
    implementation = _ml_binary,
    attrs = {
        "main": attr.label(mandatory = True, allow_single_file = True),
        "srcs": attr.label_list(allow_files = True),
        "_compiler": attr.label(
            default = "@ml_compiler//:bin/mlton",
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "_compiler_library": attr.label(
            default = "@ml_compiler//:library",
            allow_files = True,
            cfg = "host",
        )
    },
    executable = True,
)
