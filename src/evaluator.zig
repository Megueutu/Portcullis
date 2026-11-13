const std = @import("std");
const parser = @import("parser.zig");

pub fn evaluate(source: []const u8) !i64 {
    const allocator = std.heap.page_allocator;
    var expression = try parser.parse(allocator, source);
    defer expression.operations.deinit(allocator);

    var result = expression.initial;
    for (expression.operations.items) |operation| {
        result = switch (operation.operator) {
            .add => try std.math.add(i64, result, operation.operand),
            .subtract => try std.math.sub(i64, result, operation.operand),
        };
    }
    return result;
}

test "addition and subtraction associate left to right" {
    try std.testing.expectEqual(@as(i64, 42), try evaluate(" 50 - 10 + 2 "));
    try std.testing.expectEqual(@as(i64, -3), try evaluate("2-5"));
}

test "malformed expressions and overflow are reported" {
    try std.testing.expectError(error.ExpectedInteger, evaluate("1 +"));
    try std.testing.expectError(error.ExpectedOperator, evaluate("1 2"));
    try std.testing.expectError(error.InvalidCharacter, evaluate("1 * 2"));
    try std.testing.expectError(error.Overflow, evaluate("9223372036854775807 + 1"));
}
