const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub const Entry = struct {
    name: []const u8,
    kind: std.fs.File.Kind,
};

pub const Navigator = struct {
    allocator: Allocator,
    current_dir: std.fs.Dir,
    entries: ArrayList(Entry),
    selected_index: usize,

    pub fn init(allocator: Allocator) !Navigator {
        var current_dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
        var entries = ArrayList(Entry).init(allocator);
        try loadEntries(&entries, current_dir, allocator);

        return Navigator{
            .allocator = allocator,
            .current_dir = current_dir,
            .entries = entries,
            .selected_index = 0,
        };
    }

    pub fn deinit(self: *Navigator) void {
        self.current_dir.close();
        for (self.entries.items) |entry| {
            self.allocator.free(entry.name);
        }
        self.entries.deinit();
    }

    pub fn getCurrentEntries(self: *Navigator) []Entry {
        return self.entries.items;
    }

    pub fn getCurrentPath(self: *Navigator) ![]const u8 {
        return self.current_dir.realpath(".", &[_]u8{0} ** std.fs.MAX_PATH_BYTES);
    }

    pub fn moveSelection(self: *Navigator, delta: isize) !void {
        const new_index = @as(isize, @intCast(self.selected_index)) + delta;
        if (new_index >= 0 and new_index < @as(isize, @intCast(self.entries.items.len))) {
            self.selected_index = @intCast(new_index);
        }
    }

    pub fn enterSelected(self: *Navigator) !void {
        if (self.entries.items.len == 0) return;
        
        const selected = self.entries.items[self.selected_index];
        if (selected.kind != .Directory) return;

        // Store old dir to close it later
        var old_dir = self.current_dir;
        
        // Try to open new directory
        self.current_dir = try old_dir.openDir(selected.name, .{ .iterate = true });
        old_dir.close();

        // Clear entries and load new ones
        for (self.entries.items) |entry| {
            self.allocator.free(entry.name);
        }
        self.entries.clearRetainingCapacity();
        try loadEntries(&self.entries, self.current_dir, self.allocator);
        self.selected_index = 0;
    }
};

fn loadEntries(entries: *ArrayList(Entry), dir: std.fs.Dir, allocator: Allocator) !void {
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        try entries.append(.{
            .name = try allocator.dupe(u8, entry.name),
            .kind = entry.kind,
        });
    }

    // Sort entries: directories first, then files
    std.sort.sort(Entry, entries.items, {}, lessThan);
}

fn lessThan(context: void, a: Entry, b: Entry) bool {
    _ = context;
    if (a.kind == .Directory and b.kind != .Directory) return true;
    if (a.kind != .Directory and b.kind == .Directory) return false;
    return std.ascii.lessThanIgnoreCase(a.name, b.name);
}
