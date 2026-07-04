const std = @import("std");
const io = std.Io;
const mem = std.mem;

const lsm = @import("lsm.zig");


pub fn main(init: std.process.Init) !void {
    const process_io = init.io;
    const arena = init.arena.allocator();

    // var arena_allocator: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    // defer arena_allocator.deinit();
    // const arena = arena_allocator.allocator();

    var memtable = try lsm.Memtable.init(arena);

    const prng: std.Random.IoSource = .{.io = process_io};

    var input: [1024]u8 = undefined;
    var output: [1024]u8 = undefined;
    while (true) {
        var stdin_reader: io.File.Reader = io.File.stdin().reader(process_io, &input);
        var stdout_writer: io.File.Writer = io.File.stdout().writer(process_io, &output);

        var stdin: *io.Reader = &stdin_reader.interface;
        var stdout: *io.Writer = &stdout_writer.interface;

        try stdout.writeAll("Hello World\n");
        try stdout.flush();

        try stdout.writeAll("Enter cmd: ");
        try stdout.flush();

        const cmd: []u8 = stdin.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        if (cmd.len == 0) {
            try stdout.writeAll("entered blank cmd\n");
            try stdout.flush();
            break;
        }

        if (std.ascii.eqlIgnoreCase(cmd, "exit")) {
            try stdout.writeAll("goodbye\n");
            try stdout.flush();
            break;
        }

        if (std.ascii.eqlIgnoreCase(cmd, "run")) {
            const rand = prng.interface();
            const keyval = rand.int(u8);
            const valval = rand.int(u8);
            std.debug.print("key: {}, value: {}\n", .{keyval, valval});
            const tuple: lsm.Tuple = lsm.Tuple.init(keyval, valval);
            memtable.append(tuple);
        }
    }
}
