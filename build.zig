const std = @import("std");

pub fn build(b: *std.Build) void {
    const module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    const exe = b.addExecutable(.{ .name = "portcullis", .root_module = module });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    if (b.args) |args| run.addArgs(args);
    b.step("run", "Evaluate a Portcullis expression").dependOn(&run.step);

    const tests = b.addRunArtifact(b.addTest(.{ .root_module = module }));
    b.step("test", "Run language tests").dependOn(&tests.step);
}
