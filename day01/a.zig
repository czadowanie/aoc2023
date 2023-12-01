const std = @import("std");

fn isDigit(c: u8) bool {
    return (c >= '0' and c <= '9');
}

fn toNumber(c: u8) u32 {
    return c - '0';
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();

    const content = try std.io.getStdIn().readToEndAlloc(arena, 1024 * 1024);

    var first: ?u8 = null;
    var last: ?u8 = null;

    var sum: u32 = 0;
    for (content, 0..content.len) |c, i| {
        if (isDigit(c)) {
            if (first == null) {
                first = c;
                last = c;
            } else {
                last = c;
            }
        }

        if (c == '\n' or i == content.len - 1) {
            const tens_digit = toNumber(first.?);
            const ones_digit = toNumber(last.?);
            const number = tens_digit * 10 + ones_digit;
            sum += number;
            std.log.debug("{d}", .{number});

            first = null;
            last = null;
        }
    }

    std.log.info("{d}", .{sum});
}
