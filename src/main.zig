const std = @import("std");
const language = @import("language.zig");

pub fn main() !void {
    var args = try std.process.argsWithAllocator(std.heap.page_allocator);
    defer args.deinit();
    _ = args.next();
    const source = args.next() orelse {
        std.debug.print("usage: portcullis \"<expression>\"\n", .{});
        std.process.exit(2);
    };
    if (args.next() != null) {
        std.debug.print("expected one quoted expression\n", .{});
        std.process.exit(2);
    }

    const result = language.evaluate(source) catch |err| {
        std.debug.print("portcullis: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };
    var buffer: [64]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&buffer);
    try stdout.interface.print("{d}\n", .{result});
    try stdout.interface.flush();
}

test {
    _ = language;
}
