const std = @import("std");

fn isDigit(c: u8) bool {
    return (c >= '0' and c <= '9');
}

fn toNumber(c: u8) u32 {
    return c - '0';
}

fn parseDigit(buffer: []const u8, pos: usize) ?u32 {
    const candidates: []const []const u8 = &.{
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
    };
    for (candidates, 0..) |candidate, i| {
        if (candidate.len > buffer.len - pos) {
            continue;
        } else {
            if (std.mem.eql(u8, candidate, buffer[pos .. pos + candidate.len])) {
                return @intCast(i);
            } else {
                continue;
            }
        }
    }

    return null;
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();

    const content = try std.io.getStdIn().readToEndAlloc(arena, 1024 * 1024);

    var tens: ?u32 = null;
    var ones: ?u32 = null;

    var sum: u32 = 0;
    var pos: usize = 0;
    while (pos < content.len) {
        if (isDigit(content[pos])) {
            if (tens == null) {
                tens = toNumber(content[pos]);
            }
            ones = toNumber(content[pos]);
        } else if (parseDigit(content, pos)) |val| {
            if (tens == null) {
                tens = val;
            }
            ones = val;
        }

        if (content[pos] == '\n' or pos == content.len - 1) {
            const number = tens.? * 10 + ones.?;
            sum += number;
            std.log.debug("{d}", .{number});

            tens = null;
            ones = null;
        }

        pos += 1;
    }

    std.log.info("{d}", .{sum});
}
