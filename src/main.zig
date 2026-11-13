const std = @import("std");
const codegen = @import("codegen.zig");
const evaluator = @import("evaluator.zig");

pub fn main() !void {
    var args = try std.process.argsWithAllocator(std.heap.page_allocator);
    defer args.deinit();
    _ = args.next();
    const first = args.next() orelse {
        std.debug.print("usage: portcullis [emit-c] \"<expression>\"\n", .{});
        std.process.exit(2);
    };
    const emit_c = std.mem.eql(u8, first, "emit-c");
    const source = if (emit_c) args.next() orelse {
        std.debug.print("expected a quoted expression after emit-c\n", .{});
        std.process.exit(2);
    } else first;
    if (args.next() != null) {
        std.debug.print("expected one quoted expression\n", .{});
        std.process.exit(2);
    }

    var buffer: [64]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&buffer);
    if (emit_c) {
        codegen.emitC(source, &stdout.interface) catch |err| reportError(err);
        try stdout.interface.flush();
        return;
    }

    const result = evaluator.evaluate(source) catch |err| reportError(err);
    try stdout.interface.print("{d}\n", .{result});
    try stdout.interface.flush();
}

fn reportError(err: anyerror) noreturn {
    std.debug.print("portcullis: {s}\n", .{@errorName(err)});
    std.process.exit(1);
}

test {
    _ = evaluator;
}
