const std = @import("std");

const Table = struct {
    len: usize,
    times: []u32,
    distances: []u32,
};

fn parseLine(input: []const u8, pos: *usize, into: *std.ArrayList(u32)) !void {
    while (input[pos.*] != '\n') {
        if (std.ascii.isWhitespace(input[pos.*])) {
            pos.* += 1;
        } else {
            var number_len: usize = 0;
            while (std.ascii.isDigit(input[pos.* + number_len])) {
                number_len += 1;
            }
            const number = try std.fmt.parseInt(u32, input[pos.* .. pos.* + number_len], 10);
            try into.append(number);

            pos.* += number_len;
        }
    }
    pos.* += 1;
}

fn parseTable(alloc: std.mem.Allocator, input: []const u8) !Table {
    var times = std.ArrayList(u32).init(alloc);
    var distances = std.ArrayList(u32).init(alloc);

    var pos: usize = 0;

    pos += "Time:".len;
    try parseLine(input, &pos, &times);

    pos += "Distance:".len;
    try parseLine(input, &pos, &distances);

    return .{
        .len = times.items.len,
        .times = times.items,
        .distances = distances.items,
    };
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    const input = try std.io.getStdIn().reader().readAllAlloc(arena, 1024);

    const table = try parseTable(arena, input);
    std.log.debug("{any}", .{table});

    var ways_combined: u32 = 1;

    for (0..table.len) |i| {
        var ways: u32 = 0;
        for (0..table.times[i]) |held| {
            const distance = held * (table.times[i] - held);

            if (distance > table.distances[i]) {
                ways += 1;
            }
        }
        ways_combined *= ways;
    }

    std.log.debug("answer: {d}", .{ways_combined});
}
