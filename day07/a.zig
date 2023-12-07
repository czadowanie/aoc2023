const std = @import("std");

pub fn parseHand(input: []const u8) [5]u32 {
    var out: [5]u32 = undefined;

    for (0..5) |i| {
        out[i] = switch (input[i]) {
            '2'...'9' => (input[i] - '2'),
            'T' => 8,
            'J' => 9,
            'Q' => 10,
            'K' => 11,
            'A' => 12,
            else => std.debug.panic("invalid byte while parsing hand '{c}' - 0x{x}", .{ input[i], input[i] }),
        };
    }
    return out;
}

pub fn handKind(hand: [5]u32) u32 {
    var buckets = std.mem.zeroes([13]u8);
    for (&hand) |card| {
        buckets[card] += 1;
    }

    // check for 5k and 4k
    for (&buckets) |bucket| {
        if (bucket == 5) {
            return 6;
        } else if (bucket == 4) {
            return 5;
        }
    }

    // check for full house / 3k
    {
        var highest_bucket: u32 = 0;
        for (&buckets) |bucket| {
            if ((bucket == 2 and highest_bucket == 3) or (bucket == 3 and highest_bucket == 2)) {
                return 4;
            }
            highest_bucket = @max(highest_bucket, bucket);
        }

        if (highest_bucket == 3) {
            return 3;
        }
    }

    // check for 2p / 1p
    {
        var npairs: u32 = 0;
        for (&buckets) |bucket| {
            if (bucket == 2) {
                npairs += 1;
            }
        }

        if (npairs == 2) {
            return 2;
        } else if (npairs == 1) {
            return 1;
        }
    }

    // it's a high card then
    return 0;
}

const HandWithBid = struct {
    hand: [5]u32,
    bid: u32,
};

pub fn isHandLessThan(_: void, a: HandWithBid, b: HandWithBid) bool {
    const a_kind = handKind(a.hand);
    const b_kind = handKind(b.hand);
    if (a_kind < b_kind) {
        return true;
    } else if (a_kind > b_kind) {
        return false;
    } else {
        for (&a.hand, &b.hand) |a_card, b_card| {
            std.log.debug("kind {d} - cmp {d} {d}", .{ a_kind, a_card, b_card });
            if (a_card < b_card) {
                return true;
            } else if (a_card > b_card) {
                return false;
            }
        }
    }

    return false;
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = arena_state.allocator();
    const input = try std.io.getStdIn().reader().readAllAlloc(arena, 1024 * 1024);

    const lines = std.mem.count(u8, input, "\n");
    std.log.debug("lines {d}", .{lines});
    var hands = try std.ArrayList(HandWithBid).initCapacity(arena, lines);

    var pos: usize = 0;
    while (pos < input.len) {
        const hand = parseHand(input[pos..]);
        pos += 6; // skip "XXXXX "

        const start = pos;
        while (std.ascii.isDigit(input[pos])) {
            pos += 1;
        }

        const bid = try std.fmt.parseInt(u32, input[start..pos], 10);

        pos += 1; //skip newline

        std.log.debug("hand {any}, bid {d}, kind: {d}", .{ hand, bid, handKind(hand) });

        try hands.append(.{ .hand = hand, .bid = bid });
    }

    std.sort.insertion(HandWithBid, hands.items, {}, isHandLessThan);

    var winnings: usize = 0;
    for (hands.items, 0..) |hand, i| {
        std.log.debug("{d} {any} - {d}", .{ i + 1, hand.hand, hand.bid });
        winnings += (i + 1) * hand.bid;
    }

    std.log.debug("winnings: {d}", .{winnings});
}
