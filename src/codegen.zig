const std = @import("std");
const parser = @import("parser.zig");

pub fn emitC(source: []const u8, writer: *std.Io.Writer) !void {
    const allocator = std.heap.page_allocator;
    var expression = try parser.parse(allocator, source);
    defer expression.operations.deinit(allocator);

    try writer.writeAll("#include <inttypes.h>\n#include <stdio.h>\n\nint main(void) {\n");
    try writer.print("    int64_t result = INT64_C({d});\n", .{expression.initial});
    for (expression.operations.items) |operation| {
        const builtin = switch (operation.operator) {
            .add => "__builtin_add_overflow",
            .subtract => "__builtin_sub_overflow",
        };
        try writer.print("    if ({s}(result, INT64_C({d}), &result)) {{\n", .{ builtin, operation.operand });
        try writer.writeAll("        fputs(\"portcullis: Overflow\\n\", stderr);\n        return 1;\n    }\n");
    }
    try writer.writeAll("    printf(\"%\" PRId64 \"\\n\", result);\n    return 0;\n}\n");
}
