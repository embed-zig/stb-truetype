const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const embed_zig = b.dependency("embed_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const local_include = b.path("include");

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "stb_truetype",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .sanitize_c = .off,
        }),
    });
    lib.root_module.addIncludePath(local_include);
    if (b.sysroot) |sysroot| {
        lib.root_module.addSystemIncludePath(.{
            .cwd_relative = b.pathJoin(&.{ sysroot, "include" }),
        });
    }
    lib.root_module.addCSourceFile(.{
        .file = b.path("src/binding.c"),
    });

    const mod = b.createModule(.{
        .root_source_file = b.path("stb_truetype.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addIncludePath(local_include);
    if (b.sysroot) |sysroot| {
        mod.addSystemIncludePath(.{
            .cwd_relative = b.pathJoin(&.{ sysroot, "include" }),
        });
    }
    mod.addImport("embed", embed_zig.module("embed"));
    mod.linkLibrary(lib);

    b.modules.put("stb_truetype", mod) catch @panic("OOM");
    b.installArtifact(lib);

    // Tests
    const test_step = b.step("test", "Run stb_truetype tests");

    const test_mod = b.createModule(.{
        .root_source_file = b.path("stb_truetype.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_mod.addIncludePath(local_include);
    if (b.sysroot) |sysroot| {
        test_mod.addSystemIncludePath(.{
            .cwd_relative = b.pathJoin(&.{ sysroot, "include" }),
        });
    }
    test_mod.addImport("embed", embed_zig.module("embed"));
    test_mod.addImport("embed_std", embed_zig.module("embed_std"));
    test_mod.addImport("testing", embed_zig.module("testing"));
    test_mod.linkLibrary(lib);

    const tests = b.addTest(.{ .root_module = test_mod });
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
