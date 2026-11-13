const std = @import("std");

const Token = union(enum) {
    integer: i64,
    plus,
    minus,
    end,
};

const Lexer = struct {
    remaining: []const u8,

    fn next(self: *Lexer) !Token {
        self.remaining = std.mem.trimStart(u8, self.remaining, " \t\r\n");
        if (self.remaining.len == 0) return .end;

        const first = self.remaining[0];
        if (first == '+' or first == '-') {
            self.remaining = self.remaining[1..];
            return if (first == '+') .plus else .minus;
        }

        var length: usize = 0;
        while (length < self.remaining.len and std.ascii.isDigit(self.remaining[length])) {
            length += 1;
        }
        if (length == 0) return error.InvalidCharacter;

        const value = try std.fmt.parseInt(i64, self.remaining[0..length], 10);
        self.remaining = self.remaining[length..];
        return .{ .integer = value };
    }
};

fn readInteger(lexer: *Lexer) !i64 {
    return switch (try lexer.next()) {
        .integer => |value| value,
        else => error.ExpectedInteger,
    };
}

pub fn evaluate(source: []const u8) !i64 {
    var lexer = Lexer{ .remaining = source };
    var result = try readInteger(&lexer);

    while (true) {
        result = switch (try lexer.next()) {
            .plus => try std.math.add(i64, result, try readInteger(&lexer)),
            .minus => try std.math.sub(i64, result, try readInteger(&lexer)),
            .end => return result,
            .integer => return error.ExpectedOperator,
        };
    }
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
