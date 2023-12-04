const std = @import("std");

fn parseLine(
    content: []const u8,
    pos: *usize,
    winning: *[100]bool,
    yours: *[100]bool,
) !void {
    // discard "Card X"
    while (content[pos.*] != ':') {
        pos.* += 1;
    }
    pos.* += 2; // discard ": "

    var record_yours: bool = false;
    while (content[pos.* - 1] != '\n') {
        if (content[pos.*] == '|') {
            pos.* += 2; // discard "| "
            record_yours = true;
        } else {
            const number = blk: {
                if (content[pos.*] == ' ') {
                    break :blk try std.fmt.parseInt(usize, content[pos.* + 1 .. pos.* + 2], 10);
                } else {
                    break :blk try std.fmt.parseInt(usize, content[pos.* .. pos.* + 2], 10);
                }
            };

            // std.log.debug("number {d}", .{number});

            if (record_yours) {
                yours[number] = true;
            } else {
                winning[number] = true;
            }

            pos.* += 3; // discard "XX "
        }
    }
    pos.* += 1;
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena_state.allocator();
    const content = try std.io.getStdIn().reader().readAllAlloc(alloc, 1024 * 1024);

    var sum: u32 = 0;

    var pos: usize = 0;
    while (pos < content.len) {
        var winning = std.mem.zeroes([100]bool);
        var yours = std.mem.zeroes([100]bool);
        try parseLine(content, &pos, &winning, &yours);

        var matches: u32 = 0;
        for (1..100) |i| {
            matches += if (winning[i] and yours[i]) 1 else 0;
        }

        if (matches > 0) {
            sum += std.math.pow(u32, 2, matches - 1);
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum});
}
