const std = @import("std");
const io = std.Io;

pub fn main(init: std.process.Init) !void {
    var input: [1024]u8 = undefined;
    var output: [1024]u8 = undefined;

    var stdin_reader: io.File.Reader = io.File.stdin().reader(init.io, &input);
    var stdout_writer: io.File.Writer = io.File.stdout().writer(init.io, &output);
    var stdin: *io.Reader = &stdin_reader.interface;
    var stdout: *io.Writer = &stdout_writer.interface;

    try stdout.writeAll("Hello World\n");
    try stdout.flush();
    while (true) {
        try stdout.writeAll("Enter your name: ");
        try stdout.flush();

        var name: []u8 = stdin.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break, // Ctrl-D / Ctrl-Z
            else => return err,
        };

        if (name.len == 0) break;

        try stdout.print("Your name is: {s}\n", .{name});
        try stdout.flush();
    }

    try stdout.writeAll("\nDone.");
    try stdout.flush();
}
