const std = @import("std");
const math = std.math;
const debug = std.debug;
const mem = std.mem;

const VALUES_MAX_SIZE: u8 = 128;

pub const Tuple = struct {
    key: u8,
    value: u8,
};

pub const Memtable = struct {
    values: []Tuple,
    index: u8,
    values_max_size: u8,

    pub fn init(alloc: mem.Allocator) !Memtable {
        return .{
            .values_max_size = VALUES_MAX_SIZE,
            .values = try alloc.alloc(Tuple, VALUES_MAX_SIZE),
            .index = 0
        };
    }

    pub fn append(self: *Memtable, value: Tuple) void {
        if ((self.index + 1) <= self.values_max_size) {
            self.values[self.index] = value;
            self.index += 1;
            return;
        }
        debug.print("memtable value array at max size\n", .{});
        for (self.values) |val| {
            debug.print("key: {}, value: {}\n", .{val.key, val.value});
        }
        return;
    }

    pub fn dump(self: *Memtable) void {
        for (self.values, 0..) |val, idx| {
            if (idx > self.index) return;
            debug.print("key: {}, value: {}\n", .{val.key, val.value});
        }
    }
};

pub const PersistTable = struct {
    values: []Tuple,
};


