const std = @import("std");
const io = std.Io;


fn createTable(init: std.process.Init) !void {
    const dirName = "zig-out/bin/db";
    const fileName = "table";

    const process_io = init.io;
    const cwd: std.Io.Dir = std.Io.Dir.cwd();

    cwd.createDir(process_io, dirName, .default_dir) catch |e| switch (e) {
        error.PathAlreadyExists => {
            std.debug.print("Warning: Dir already exists: {s}\n", .{"db"});
        },
        else => return e,
    };
    
    var db_dir: std.Io.Dir = try cwd.openDir(process_io, dirName, .{});
    defer db_dir.close(process_io);

    const file: std.Io.File = try db_dir.createFile(process_io, fileName, .{});
    defer file.close(process_io);


    var file_writer = file.writer(process_io, &.{});
    const writer = &file_writer.interface;

    const byte_written = try writer.write("It's zigling time!");
    std.debug.print("Successfully wrote {d} bytes.\n", .{byte_written});
}

pub fn main(init: std.process.Init) !void {
    var input: [1024]u8 = undefined;
    var output: [1024]u8 = undefined;

    while (true) {
        var stdin_reader: io.File.Reader = io.File.stdin().reader(init.io, &input);
        var stdout_writer: io.File.Writer = io.File.stdout().writer(init.io, &output);

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

        if (std.ascii.eqlIgnoreCase(cmd, "create-table")) {
            try createTable(init);
            try stdout.writeAll("created table\n");
            try stdout.flush();
        }

    }
}
