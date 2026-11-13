const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

fn readInteger(lexer: *Lexer) !i64 {
    return switch (try lexer.next()) {
        .integer => |value| value,
        else => error.ExpectedInteger,
    };
}

const Operation = struct {
    operator: enum { add, subtract },
    operand: i64,
};

pub const Expression = struct {
    initial: i64,
    operations: std.ArrayList(Operation) = .empty,
};

// expression = integer { ("+" | "-") integer }
pub fn parse(allocator: std.mem.Allocator, source: []const u8) !Expression {
    var lexer = Lexer{ .remaining = source };
    var expression = Expression{ .initial = try readInteger(&lexer) };
    errdefer expression.operations.deinit(allocator);

    while (true) {
        const operator: @FieldType(Operation, "operator") = switch (try lexer.next()) {
            .plus => .add,
            .minus => .subtract,
            .end => return expression,
            .integer => return error.ExpectedOperator,
        };
        try expression.operations.append(allocator, .{
            .operator = operator,
            .operand = try readInteger(&lexer),
        });
    }
}
