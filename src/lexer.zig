const std = @import("std");

pub const Token = union(enum) {
    integer: i64,
    plus,
    minus,
    end,
};

pub const Lexer = struct {
    remaining: []const u8,

    pub fn next(self: *Lexer) !Token {
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
