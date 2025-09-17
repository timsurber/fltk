# Fast Light Tool Kit (FLTK)
The Fast Light Tool Kit (FLTK) is a cross-platform C++ GUI toolkit for UNIX®/Linux® (X11 or Wayland), Microsoft® Windows®, and macOS®.

## Zig build for [FLTK](https://github.com/fltk/fltk).


### :rocket: Usage


```zig
//build.zig
const std = @import("std");

const linux_system_libs = [_][]const u8{
    "pthread",
    "dl",
    "m",
    "X11",
};

const windows_system_libs = [_][]const u8{
    "gdi32",
    "user32",
    "shell32",
    "ole32",
    "oleaut32",
    "uuid",
    "comctl32",
    "comdlg32",
    "advapi32",
    "ws2_32",
    "winspool",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const os_tag = target.result.os.tag;

    if (os_tag != .linux and os_tag != .windows) {
        @panic("zig build currently supports only Linux (X11) and Windows (WinAPI) targets");
    }

    const fltk_pkg = b.dependency("fltk_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const fltk_sources = b.dependency("fltk", .{});
    const fltk_lib = fltk_pkg.artifact("fltk");

    const system_libs = switch (os_tag) {
        .linux => &linux_system_libs,
        .windows => &windows_system_libs,
        else => unreachable,
    };

    const cxx_flags = [_][]const u8{"-std=c++11"};

    const tree_simple = b.addExecutable(.{
        .name = "tree-simple",
        .target = target,
        .optimize = optimize,
    });

    tree_simple.linkLibC();
    tree_simple.linkLibCpp();

    tree_simple.root_module.addIncludePath(fltk_sources.path("."));
    tree_simple.root_module.addIncludePath(fltk_sources.path("src"));
    tree_simple.root_module.addIncludePath(fltk_sources.path("FL"));
    tree_simple.root_module.addIncludePath(fltk_pkg.path("zig-config"));

    tree_simple.root_module.addCSourceFile(.{
        .file = fltk_sources.path("examples/tree-simple.cxx"),
        .flags = &cxx_flags,
        .language = .cpp,
    });

    tree_simple.linkLibrary(fltk_lib);
    for (system_libs) |syslib| {
        tree_simple.linkSystemLibrary(syslib);
    }

    const tree_simple_install = b.addInstallArtifact(tree_simple, .{});
    const tree_simple_step = b.step("tree-simple", "Build the tree-simple example");
    tree_simple_step.dependOn(&tree_simple_install.step);
}
```

```zig
// build.zig.zon
.{
    .name = .fltk_zig_example,
    .version = "0.0.0",
    .fingerprint = 0xa34db3c4bc00e416,
    .minimum_zig_version = "0.14.1",

    .dependencies = .{
        .fltk_zig = .{
            .path = "../fltk_zig",
        },
        .fltk = .{
            .url = "https://github.com/fltk/fltk/releases/download/release-1.4.4/fltk-1.4.4-source.tar.gz",
            .hash = "N-V-__8AAHXabQGMcsjcykXANFOORO1KlKyEeD66HKuQI3T2",
        },
    },
    .paths = .{ "build.zig", "build.zig.zon", "src" },
}

```