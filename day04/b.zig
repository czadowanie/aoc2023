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

fn processCards(alloc: std.mem.Allocator, content: []const u8) ![]u32 {
    const lines = std.mem.count(u8, content, "\n");

    var cards_matches = try alloc.alloc(u32, lines);

    var card: usize = 0;
    var pos: usize = 0;
    while (pos < content.len) {
        var winning = std.mem.zeroes([100]bool);
        var yours = std.mem.zeroes([100]bool);
        try parseLine(content, &pos, &winning, &yours);

        var matches: u32 = 0;
        for (1..100) |i| {
            matches += if (winning[i] and yours[i]) 1 else 0;
        }

        cards_matches[card] = matches;
        card += 1;
    }

    return cards_matches;
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena_state.allocator();
    const content = try std.io.getStdIn().reader().readAllAlloc(alloc, 1024 * 1024);

    const matches = try processCards(alloc, content);
    var amounts = try alloc.alloc(u32, matches.len);
    for (amounts) |*amount| {
        amount.* = 1;
    }

    for (matches, amounts, 0..) |matched, amount, i| {
        for (i + 1..i + matched + 1) |card| {
            amounts[card] += amount;
        }
    }

    std.log.debug("matches {any}", .{matches});
    std.log.debug("amounts {any}", .{amounts});

    var sum: u32 = 0;
    for (amounts) |amount| {
        sum += amount;
    }

    std.log.debug("sum {d}", .{sum});
}
