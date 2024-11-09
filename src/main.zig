const std = @import("std");
const term = @import("terminal.zig");
const ui = @import("ui.zig");
const nav = @import("navigator.zig");

pub fn main() !void {
    // Setup terminal
    try term.enableRawMode();
    defer term.disableRawMode();

    // Initialize navigator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var navigator = try nav.Navigator.init(allocator);
    defer navigator.deinit();

    // Main event loop
    try ui.run(&navigator);
}
