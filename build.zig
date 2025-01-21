const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // your http server executable
    const exe = b.addExecutable(.{
        .name = "zap-myzql-example",
        .root_source_file = b.path("./src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // add zap dependency
    const zap = b.dependency("zap", .{
        .target = target,
        .optimize = optimize,
        .openssl = false, // set to true to enable TLS support
    });
    exe.root_module.addImport("zap", zap.module("zap"));

    // add zap dependency
    const myzql_dep = b.dependency("myzql", .{});
    const myzql = myzql_dep.module("myzql");
    exe.root_module.addImport("myzql", myzql);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
