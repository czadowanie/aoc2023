const std = @import("std");

const Table = struct {
    time: u64,
    distance: u64,
};

fn parseLine(alloc: std.mem.Allocator, input: []const u8, pos: *usize) !u64 {
    var number = std.ArrayList(u8).init(alloc);
    defer number.deinit();

    while (input[pos.*] != '\n') {
        if (std.ascii.isDigit(input[pos.*])) {
            try number.append(input[pos.*]);
        }

        pos.* += 1;
    }

    pos.* += 1;

    return try std.fmt.parseInt(u64, number.items, 10);
}

fn parseTable(alloc: std.mem.Allocator, input: []const u8) !Table {
    var pos: usize = 0;

    return .{
        .time = try parseLine(alloc, input, &pos),
        .distance = try parseLine(alloc, input, &pos),
    };
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    const input = try std.io.getStdIn().reader().readAllAlloc(arena, 1024);

    const table = try parseTable(arena, input);
    std.log.debug("{any}", .{table});

    var ways: u64 = 0;
    for (0..table.time) |held| {
        const distance = held * (table.time - held);

        if (distance > table.distance) {
            ways += 1;
        }
    }

    std.log.debug("answer: {d}", .{ways});
}
